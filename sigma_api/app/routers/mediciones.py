from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc, func
from typing import Dict, Any, List
from datetime import datetime, timedelta
from app.database import get_db
from app.models.database_models import Medicion, Sensor, Dispositivo, Configuracion  # ← agregado Configuracion

router = APIRouter(prefix="/api/mediciones", tags=["mediciones"])

# Mapeo de nombres de sensores a sensor_id (basado en tu INSERT inicial)
SENSOR_MAPPING = {
    "temperatura": 1,  # SHT75 - Temperatura
    "humedad": 2,      # SHT75 - Humedad  
    "luminosidad": 3,  # LDR - Luminosidad
    "humedad_suelo": 4 # Watermark - Humedad Suelo
}

SENSOR_NAMES = {v: k for k, v in SENSOR_MAPPING.items()}

# Variables globales para modo manual y control de intervalo
ultima_medicion_recibida = None
ultimo_guardado_timestamp = None

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
        "luminosidad": 450.0,
        "humedad_suelo": 45.8
    }
    """
    global ultima_medicion_recibida, ultimo_guardado_timestamp
    
    print(f"📊 Recibiendo mediciones: {datos}")
    
    if not datos:
        raise HTTPException(status_code=400, detail="No se recibieron datos")
    
    # Guardar la última medición para modo manual
    ultima_medicion_recibida = datos.copy()
    
    # Obtener intervalo de configuración
    config = db.query(Configuracion).filter(Configuracion.clave == "auto_intervalo_minutos").first()
    intervalo_minutos = int(config.valor) if config else 5
    
    # Decidir si guardar automáticamente
    ahora = datetime.now()
    guardar_auto = False
    
    if ultimo_guardado_timestamp is None:
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
        for tipo_sensor, valor in datos.items():
            if tipo_sensor in SENSOR_MAPPING and valor is not None:
                sensor_id = SENSOR_MAPPING[tipo_sensor]
                medicion = Medicion(sensor_id=sensor_id, valor=float(valor), calidad="buena")
                db.add(medicion)
        
        db.commit()
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
    sensor: str = Query(None, description="Tipo de sensor (temperatura, humedad, etc)"),
    db: Session = Depends(get_db)
):
    """
    Obtiene mediciones históricas para gráficos
    """
    try:
        # Calcular timestamp de inicio
        start_time = datetime.now() - timedelta(hours=horas)
        
        query = db.query(Medicion).filter(
            Medicion.timestamp >= start_time
        )
        
        # Filtrar por sensor si se especifica
        if sensor and sensor in SENSOR_MAPPING:
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
                "sensor": sensor,
                "desde": start_time.isoformat()
            }
        }
        
    except Exception as e:
        print(f"❌ Error obteniendo datos históricos: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")