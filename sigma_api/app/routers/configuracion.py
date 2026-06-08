from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.database_models import Configuracion
from app.dependencies import get_current_active_admin

router = APIRouter(prefix="/api/config", tags=["configuracion"])

@router.get("/auto-interval")
def get_auto_interval(db: Session = Depends(get_db)):
    """Obtiene el intervalo automático en minutos"""
    config = db.query(Configuracion).filter(Configuracion.clave == "auto_intervalo_minutos").first()
    if not config:
        raise HTTPException(status_code=404, detail="Configuración no encontrada")
    return {"clave": config.clave, "valor": int(config.valor)}

@router.put("/auto-interval")
def set_auto_interval(
    intervalo: int,
    db: Session = Depends(get_db),
    admin=Depends(get_current_active_admin)  # solo admin puede cambiar
):
    """Actualiza el intervalo automático (solo admin)"""
    if intervalo < 1:
        raise HTTPException(status_code=400, detail="El intervalo debe ser mayor a 0 minutos")
    
    config = db.query(Configuracion).filter(Configuracion.clave == "auto_intervalo_minutos").first()
    if not config:
        raise HTTPException(status_code=404, detail="Configuración no encontrada")
    
    config.valor = str(intervalo)
    db.commit()
    return {"message": f"Intervalo actualizado a {intervalo} minutos"}
