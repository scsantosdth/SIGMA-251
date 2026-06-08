# sigma_api/app/utils/auth_utils.py
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.config import settings

# Configuración para hashing de passwords
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Función para verificar password
def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica si el password plano coincide con el hash"""
    return pwd_context.verify(plain_password, hashed_password)

# Función para hashear password
def get_password_hash(password: str) -> str:
    """Genera hash del password"""
    return pwd_context.hash(password)

# Función para crear token JWT
def create_access_token(data: dict, expires_delta: timedelta = None):
    """Crea un token JWT con los datos proporcionados"""
    to_encode = data.copy()
    
    # Configurar tiempo de expiración
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt

# Función para verificar token JWT
def verify_token(token: str):
    """Verifica y decodifica un token JWT"""
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        return payload
    except JWTError:
        return None