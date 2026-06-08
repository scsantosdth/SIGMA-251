from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from app.database import Base, engine
from app.models.database_models import Configuracion
from app.routers import auth, configuracion, estado_sistema, mediciones

# Crear tablas en la BD
Base.metadata.create_all(bind=engine)


def init_config():
    db = Session(bind=engine)
    try:
        intervalo = (
            db.query(Configuracion)
            .filter(Configuracion.clave == "auto_intervalo_minutos")
            .first()
        )
        if not intervalo:
            config = Configuracion(
                clave="auto_intervalo_minutos",
                valor="5",
                descripcion="Intervalo en minutos para almacenamiento automatico de mediciones",
            )
            db.add(config)
            db.commit()
            print("Configuracion por defecto creada: auto_intervalo_minutos = 5")
        else:
            print("Configuracion existente encontrada")
    except Exception as e:
        print(f"Error inicializando configuracion: {e}")
        db.rollback()
    finally:
        db.close()


init_config()

app = FastAPI(
    title="SIGMA API",
    description="API para sistema de monitoreo de sensores Waspmote",
    version="1.0.0",
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(mediciones.router)
app.include_router(estado_sistema.router)
app.include_router(auth.router)
app.include_router(configuracion.router)


@app.get("/")
async def root():
    return {
        "message": "SIGMA API - Sistema de Gestion de Monitoreo Ambiental",
        "status": "online",
    }


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
