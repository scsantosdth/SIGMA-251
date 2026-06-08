import os
from dotenv import load_dotenv

load_dotenv()  # Carga variables desde .env (solo desarrollo local)

class Settings:
    # Base de datos: usa variable de entorno o un valor por defecto local
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "postgresql://postgres:sergio123@localhost:5432/SIGMA"
    )
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "clave_secreta_jwt_desarrollo_cambiar_en_produccion")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 horas

settings = Settings()