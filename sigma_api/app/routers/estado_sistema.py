from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import desc
from typing import Dict, Any, List
from datetime import datetime, timedelta
from app.database import get_db
from app.models.database_models import EstadoSistema, EventoSistema

router = APIRouter(prefix="/api/estado-sistema", tags=["estado-sistema"])

def parse_timestamp(value):
    if not value:
        return None

    try:
        timestamp = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        if timestamp.tzinfo is not None:
            timestamp = timestamp.replace(tzinfo=None)
        return timestamp
    except ValueError:
        return None

@router.post("/waspmote")
async def recibir_estado_waspmote(
    datos: Dict[str, Any], 
    db: Session = Depends(get_db)
):
    """
    Recibe estado del sistema del Waspmote
    Formato esperado: {
        "dispositivo_id": 1,
        "bateria": 85.5
    }
    """
    try:
        print(f"🔋 Recibiendo estado del sistema: {datos}")
        
        dispositivo_id = datos.get("dispositivo_id", 1)  # Default al Waspmote principal
        bateria = datos.get("bateria")
        
        if bateria is None:
            raise HTTPException(status_code=400, detail="Campo 'bateria' requerido")
        
        # Guardar estado del sistema
        estado = EstadoSistema(
            dispositivo_id=dispositivo_id,
            bateria=float(bateria),
            estado_conexion=True,
            timestamp=parse_timestamp(datos.get("timestamp")) or datetime.now()
        )
        
        db.add(estado)
        
        # Crear evento si la batería está baja
        if bateria < 20:
            evento = EventoSistema(
                dispositivo_id=dispositivo_id,
                tipo="advertencia",
                severidad="media",
                mensaje=f"Batería baja: {bateria}%"
            )
            db.add(evento)
        
        db.commit()
        
        return {
            "status": "success", 
            "message": f"Estado guardado - Batería: {bateria}%",
            "bateria": bateria
        }
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error guardando estado: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.get("/waspmote/latest")
async def obtener_ultimo_estado(db: Session = Depends(get_db)):
    """
    Obtiene el último estado del sistema (batería)
    """
    try:
        # Obtener el último estado
        latest_state = db.query(EstadoSistema).order_by(
            desc(EstadoSistema.timestamp)
        ).first()
        
        if not latest_state:
            raise HTTPException(status_code=404, detail="No se encontraron datos de estado")
        
        return {
            "status": "success",
            "data": {
                "dispositivo_id": latest_state.dispositivo_id,
                "bateria": latest_state.bateria,
                "estado_conexion": latest_state.estado_conexion,
                "timestamp": latest_state.timestamp.isoformat()
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"❌ Error obteniendo último estado: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")

@router.get("/waspmote/historical")
async def obtener_estado_historico(
    horas: int = Query(24, description="Número de horas hacia atrás"),
    db: Session = Depends(get_db)
):
    """
    Obtiene estado histórico del sistema para gráficos
    """
    try:
        # Calcular timestamp de inicio
        start_time = datetime.now() - timedelta(hours=horas)
        
        # Obtener estados históricos
        states = db.query(EstadoSistema).filter(
            EstadoSistema.timestamp >= start_time
        ).order_by(EstadoSistema.timestamp).all()
        
        # Formatear respuesta
        historical_data = []
        for state in states:
            historical_data.append({
                "bateria": state.bateria,
                "estado_conexion": state.estado_conexion,
                "timestamp": state.timestamp.isoformat()
            })
        
        return {
            "status": "success",
            "data": historical_data,
            "filtros": {
                "horas": horas,
                "desde": start_time.isoformat()
            }
        }
        
    except Exception as e:
        print(f"❌ Error obteniendo estado histórico: {e}")
        raise HTTPException(status_code=500, detail=f"Error interno: {str(e)}")
