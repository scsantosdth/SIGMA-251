from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import Dict, Any, List
from datetime import datetime, timedelta, timezone
from app.database import get_db
from app.models.database_models import Medicion, Sensor, Dispositivo, Configuracion  # ← agregado Configuracion

router = APIRouter(prefix="/api/mediciones", tags=["mediciones"])

# Mapeo de nombres de sensores a sensor_id 
SENSOR_MAPPING = {
    "temperatura": 1,  # SHT75 - Temperatura
    "humedad": 2,      # SHT75 - Humedad  
    "radiacion_solar": 3,  # SR11-TR - Radiacion solar
    # Clave historica de la API; el valor almacenado es TA en cbar.
    "humedad_suelo": 4 # Watermark - Tension Agua Suelo
}

SENSOR_NAMES = {v: k for k, v in SENSOR_MAPPING.items()}

# Variables globales para modo manual y control de intervalo
ultima_medicion_recibida = None
ultimo_guardado_timestamp = None

def parse_timestamp(value):
    if not value:
        return None

    try:
        timestamp = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        if timestamp.tzinfo is not None:
            # Guardar como UTC naive porque la columna de Supabase es TIMESTAMPTZ
            # y SQLAlchemy devuelve este modelo sin informacion de zona.
            timestamp = timestamp.astimezone(timezone.utc).replace(tzinfo=None)
        return timestamp
    except ValueError:
        return None

@router.post("/waspmote")
async def recibir_mediciones_waspmote(
    datos: Dict[str, Any], 
    db: Session = Depends(get_db)
):
    """
    Recibe datos del Waspmote y los almacena en la BD según intervalo configurado.
    Formato esperado: {
        "temperatura": 25.5,
        "humedad": 60.2, 
        "radiacion_solar": 450.0,
        "humedad_suelo": 45.8  # Tension de agua del suelo (cbar)
    }
    """
    global ultima_medicion_recibida, ultimo_guardado_timestamp
    
    print(f"📊 Recibiendo mediciones: {datos}")
    
    if not datos:
        raise HTTPException(status_code=400, detail="No se recibieron datos")
    
    # Guardar la última medición para modo manual
    ultima_medicion_recibida = datos.copy()
    offline_sync = bool(datos.get("offline_sync"))
    timestamp_medicion = parse_timestamp(datos.get("timestamp")) or datetime.now()
    
    # Obtener intervalo de configuración
    config = db.query(Configuracion).filter(Configuracion.clave == "auto_intervalo_minutos").first()
    intervalo_minutos = int(config.valor) if config else 5
    
    # Decidir si guardar automáticamente
    ahora = datetime.now()
    guardar_auto = False
    
    if offline_sync:
        guardar_auto = True
    elif ultimo_guardado_timestamp is None:
        guardar_auto = True
    else:
        diferencia = ahora - ultimo_guardado_timestamp
        if diferencia >= timedelta(minutes=intervalo_minutos):
            guardar_auto = True
    
    if not guardar_auto:
        print(f"⏱️ No se guarda automáticamente (intervalo {intervalo_minutos} min). Próximo guardado en breve.")
        return {
            "status": "skipped",
            "message": f"Guardado automático cada {intervalo_minutos} minutos. Último guardado: {ultimo_guardado_timestamp}",
            "datos_recibidos": datos
        }
    
    # Guardar mediciones automáticamente
    try:
        if offline_sync:
            # En modo sincronizacion se aplica la misma deduplicacion que en
            # /waspmote/sd para garantizar que solo se inserte lo faltante y
            # nunca se sobrescriban ni dupliquen registros ya almacenados.
            intervalo_segundos = intervalo_minutos * 60
            epoch = datetime(1970, 1, 1)
            bucket_number = int((timestamp_medicion - epoch).total_seconds() // intervalo_segundos)
            bucket_start = epoch + timedelta(seconds=bucket_number * intervalo_segundos)
            bucket_end = bucket_start + timedelta(seconds=intervalo_segundos)

        for tipo_sensor, valor in datos.items():
            if tipo_sensor in SENSOR_MAPPING and valor is not None:
                sensor_id = SENSOR_MAPPING[tipo_sensor]

                ya_existe = db.query(Medicion).filter(
                    Medicion.sensor_id == sensor_id,
                    Medicion.timestamp == timestamp_medicion
                ).first()

                if ya_existe is None and offline_sync:
                    ya_existe = db.query(Medicion).filter(
                        Medicion.sensor_id == sensor_id,
                        Medicion.timestamp >= bucket_start,
                        Medicion.timestamp < bucket_end
                    ).first()

                if ya_existe:
                    continue

                medicion = Medicion(
                    sensor_id=sensor_id,
                    valor=float(valor),
                    calidad="buena",
                    timestamp=timestamp_medicion
                )
                db.add(medicion)
        
        db.commit()
        if not offline_sync:
            ultimo_guardado_timestamp = ahora
        
        return {
            "status": "success",
            "message": f"Mediciones guardadas automáticamente (intervalo {intervalo_minutos} min)",
            "datos_recibidos": datos
        }
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error guardando mediciones: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.post("/waspmote/sd")
async def recibir_medicion_sd(
    datos: Dict[str, Any],
    db: Session = Depends(get_db)
):
    """Recibe un registro historico de la SD de forma idempotente."""
    if not datos:
        raise HTTPException(status_code=400, detail="No se recibieron datos SD")

    timestamp_medicion = parse_timestamp(datos.get("timestamp"))
    if timestamp_medicion is None:
        raise HTTPException(status_code=400, detail="El timestamp del RTC no es valido")

    insertados = []
    duplicados = []
    omitidos_intervalo = []

    config = db.query(Configuracion).filter(
        Configuracion.clave == "auto_intervalo_minutos"
    ).first()
    intervalo_minutos = int(config.valor) if config else 5
    intervalo_segundos = intervalo_minutos * 60
    epoch = datetime(1970, 1, 1)
    bucket_number = int((timestamp_medicion - epoch).total_seconds() // intervalo_segundos)
    bucket_start = epoch + timedelta(seconds=bucket_number * intervalo_segundos)
    bucket_end = bucket_start + timedelta(seconds=intervalo_segundos)

    try:
        for tipo_sensor, valor in datos.items():
            if tipo_sensor not in SENSOR_MAPPING or valor is None:
                continue

            sensor_id = SENSOR_MAPPING[tipo_sensor]
            existente = db.query(Medicion).filter(
                Medicion.sensor_id == sensor_id,
                Medicion.timestamp == timestamp_medicion
            ).first()

            if existente:
                duplicados.append(tipo_sensor)
                continue

            existente_intervalo = db.query(Medicion).filter(
                Medicion.sensor_id == sensor_id,
                Medicion.timestamp >= bucket_start,
                Medicion.timestamp < bucket_end
            ).first()
            if existente_intervalo:
                omitidos_intervalo.append(tipo_sensor)
                continue

            db.add(Medicion(
                sensor_id=sensor_id,
                valor=float(valor),
                calidad="sd",
                timestamp=timestamp_medicion
            ))
            insertados.append(tipo_sensor)

        db.commit()
        if insertados:
            status = "success"
        elif omitidos_intervalo:
            status = "skipped_interval"
        else:
            status = "duplicate"

        return {
            "status": status,
            "insertados": insertados,
            "duplicados": duplicados,
            "omitidos_intervalo": omitidos_intervalo,
            "intervalo_minutos": intervalo_minutos,
            "timestamp": timestamp_medicion.isoformat()
        }
    except Exception as e:
        db.rollback()
        print(f"Error guardando registro SD: {e}")
        raise HTTPException(status_code=500, detail=f"Error guardando registro SD: {str(e)}")

@router.post("/manual")
async def guardar_medicion_manual(db: Session = Depends(get_db)):
    """
    Guarda la última medición recibida del Waspmote (modo manual).
    Útil para tomar una lectura inmediata sin esperar el intervalo automático.
    """
    global ultima_medicion_recibida
    
    if ultima_medicion_recibida is None:
        raise HTTPException(status_code=404, detail="No hay mediciones recibidas aún")
    
    datos = ultima_medicion_recibida
    try:
        for tipo_sensor, valor in datos.items():
            if tipo_sensor in SENSOR_MAPPING and valor is not None:
                sensor_id = SENSOR_MAPPING[tipo_sensor]
                medicion = Medicion(sensor_id=sensor_id, valor=float(valor), calidad="buena")
                db.add(medicion)
        db.commit()
        return {
            "status": "success",
            "message": "Medición manual guardada correctamente",
            "datos_guardados": datos
        }
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Error al guardar medición manual: {str(e)}")

@router.get("/observar")
async def observar_mediciones(
    fecha: str = Query(None, description="Fecha local de Colombia en formato YYYY-MM-DD"),
    hora: int = Query(None, ge=0, le=23, description="Hora local de Colombia (0-23). Requiere el parámetro fecha."),
    sensor: str = Query(None, description="Tipo de sensor (temperatura, humedad, radiacion_solar, humedad_suelo)"),
    desde: str = Query(None, description="Timestamps ISO iguales o posteriores a este valor"),
    hasta: str = Query(None, description="Timestamps ISO anteriores a este valor"),
    limite: int = Query(5000, ge=1, le=50000, description="Cantidad maxima de registros a devolver"),
    offset: int = Query(0, ge=0, description="Desplazamiento para paginacion"),
    db: Session = Depends(get_db)
):
    """
    Solo LECTURA: devuelve mediciones sin crear, modificar ni eliminar nada.
    Permite observar todo el historico de la base de datos con filtros y
    paginacion. No ejecuta ninguna instruccion de escritura.
    """
    try:
        query = db.query(Medicion)
        total_query = db.query(func.count(Medicion.id))

        if desde:
            start_ts = parse_timestamp(desde)
            if start_ts is None:
                raise HTTPException(status_code=400, detail="'desde' debe ser una fecha ISO valida")
            query = query.filter(Medicion.timestamp >= start_ts)
            total_query = total_query.filter(Medicion.timestamp >= start_ts)

        if hasta:
            end_ts = parse_timestamp(hasta)
            if end_ts is None:
                raise HTTPException(status_code=400, detail="'hasta' debe ser una fecha ISO valida")
            query = query.filter(Medicion.timestamp < end_ts)
            total_query = total_query.filter(Medicion.timestamp < end_ts)

        if fecha:
            try:
                selected_date = datetime.strptime(fecha, "%Y-%m-%d").date()
            except ValueError:
                raise HTTPException(status_code=400, detail="La fecha debe tener formato YYYY-MM-DD")

            colombia_timezone = timezone(timedelta(hours=-5))
            start_time = datetime.combine(selected_date, datetime.min.time(), tzinfo=colombia_timezone)
            start_time = start_time.astimezone(timezone.utc).replace(tzinfo=None)
            end_time = start_time + timedelta(days=1)

            if hora is not None:
                start_time = start_time + timedelta(hours=hora)
                end_time = start_time + timedelta(hours=1)

            query = query.filter(
                Medicion.timestamp >= start_time,
                Medicion.timestamp < end_time
            )
            total_query = total_query.filter(
                Medicion.timestamp >= start_time,
                Medicion.timestamp < end_time
            )

        if sensor:
            if sensor not in SENSOR_MAPPING:
                raise HTTPException(
                    status_code=400,
                    detail=f"Sensor '{sensor}' no válido. Opciones: {', '.join(SENSOR_MAPPING.keys())}"
                )
            query = query.filter(Medicion.sensor_id == SENSOR_MAPPING[sensor])
            total_query = total_query.filter(Medicion.sensor_id == SENSOR_MAPPING[sensor])

        total = total_query.scalar() or 0
        mediciones = (
            query.order_by(Medicion.timestamp.asc(), Medicion.id.asc())
            .offset(offset)
            .limit(limite)
            .all()
        )

        data = [
            {
                "sensor": SENSOR_NAMES.get(m.sensor_id, f"sensor_{m.sensor_id}"),
                "sensor_id": m.sensor_id,
                "valor": m.valor,
                "calidad": m.calidad,
                "timestamp": m.timestamp.isoformat() if m.timestamp else None,
            }
            for m in mediciones
        ]

        return {
            "status": "success",
            "data": data,
            "total": total,
            "offset": offset,
            "limite": limite,
            "filtros": {
                "fecha": fecha,
                "hora": hora,
                "sensor": sensor,
                "desde": desde,
                "hasta": hasta,
            },
        }
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error obteniendo mediciones para observacion: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.get("/observar/rango")
async def observar_rango_mediciones(db: Session = Depends(get_db)):
    """
    Solo LECTURA: devuelve el periodo (min/max timestamp) cubierto por las
    mediciones en la base de datos, para saber que fechas existen.
    No ejecuta ninguna instruccion de escritura.
    """
    try:
        min_ts = db.query(func.min(Medicion.timestamp)).scalar()
        max_ts = db.query(func.max(Medicion.timestamp)).scalar()
        total = db.query(func.count(Medicion.id)).scalar() or 0

        return {
            "status": "success",
            "total": total,
            "desde": min_ts.isoformat() if min_ts else None,
            "hasta": max_ts.isoformat() if max_ts else None,
        }
    except Exception as e:
        print(f"❌ Error obteniendo rango de mediciones: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.get("/waspmote/latest")
async def obtener_ultimas_mediciones(db: Session = Depends(get_db)):
    """
    Obtiene las últimas mediciones de todos los sensores
    """
    try:
        latest_measurements = {}
        
        for sensor_id, sensor_name in SENSOR_NAMES.items():
            # Obtener la última medición para cada sensor
            latest = db.query(Medicion).filter(
                Medicion.sensor_id == sensor_id
            ).order_by(desc(Medicion.timestamp)).first()
            
            if latest:
                latest_measurements[sensor_name] = {
                    "valor": latest.valor,
                    "timestamp": latest.timestamp.isoformat(),
                    "calidad": latest.calidad
                }
            else:
                latest_measurements[sensor_name] = None
        
        return {
            "status": "success",
            "data": latest_measurements,
            "timestamp": datetime.now().isoformat()
        }
        
    except Exception as e:
        print(f"❌ Error obteniendo últimas mediciones: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.get("/waspmote/historical")
async def obtener_mediciones_historicas(
    horas: int = Query(24, description="Número de horas hacia atrás"),
    fecha: str = Query(None, description="Fecha local de Colombia en formato YYYY-MM-DD"),
    hora: int = Query(None, ge=0, le=23, description="Hora local de Colombia (0-23). Requiere el parámetro fecha."),
    sensor: str = Query(None, description="Tipo de sensor (temperatura, humedad, etc)"),
    db: Session = Depends(get_db)
):
    """
    Obtiene mediciones históricas para gráficos.
    - Con 'fecha' consulta un día completo (zona horaria Colombia UTC-5).
    - Con 'fecha' + 'hora' consulta únicamente esa hora del día.
    - Con 'sensor' filtra por una sola variable.
    """
    try:
        if fecha:
            try:
                selected_date = datetime.strptime(fecha, "%Y-%m-%d").date()
            except ValueError:
                raise HTTPException(status_code=400, detail="La fecha debe tener formato YYYY-MM-DD")

            colombia_timezone = timezone(timedelta(hours=-5))
            start_time = datetime.combine(selected_date, datetime.min.time(), tzinfo=colombia_timezone)
            start_time = start_time.astimezone(timezone.utc).replace(tzinfo=None)
            end_time = start_time + timedelta(days=1)

            if hora is not None:
                start_time = start_time + timedelta(hours=hora)
                end_time = start_time + timedelta(hours=1)

            query = db.query(Medicion).filter(
                Medicion.timestamp >= start_time,
                Medicion.timestamp < end_time
            )
        else:
            if hora is not None:
                raise HTTPException(
                    status_code=400,
                    detail="El parámetro hora requiere especificar una fecha (fecha=YYYY-MM-DD)"
                )

            # Calcular timestamp de inicio para los filtros normales 1/6/24 h.
            start_time = datetime.now() - timedelta(hours=horas)
            end_time = None
            query = db.query(Medicion).filter(
                Medicion.timestamp >= start_time
            )
        
        # Filtrar por sensor si se especifica
        if sensor:
            if sensor not in SENSOR_MAPPING:
                raise HTTPException(
                    status_code=400,
                    detail=f"Sensor '{sensor}' no válido. Opciones: {', '.join(SENSOR_MAPPING.keys())}"
                )
            sensor_id = SENSOR_MAPPING[sensor]
            query = query.filter(Medicion.sensor_id == sensor_id)
        
        # Ordenar por timestamp
        measurements = query.order_by(Medicion.timestamp).all()
        
        # Formatear respuesta
        historical_data = []
        for meas in measurements:
            historical_data.append({
                "sensor": SENSOR_NAMES.get(meas.sensor_id, f"sensor_{meas.sensor_id}"),
                "valor": meas.valor,
                "timestamp": meas.timestamp.isoformat(),
                "calidad": meas.calidad
            })
        
        return {
            "status": "success",
            "data": historical_data,
            "filtros": {
                "horas": horas,
                "fecha": fecha,
                "hora": hora,
                "sensor": sensor,
                "desde": start_time.isoformat(),
                "hasta": end_time.isoformat() if end_time else None
            }
        }
        
    except Exception as e:
        print(f"❌ Error obteniendo datos históricos: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")
