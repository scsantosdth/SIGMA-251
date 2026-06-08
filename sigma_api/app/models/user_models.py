# sigma_api/app/models/user_models.py
from pydantic import BaseModel, validator
from typing import Optional
from datetime import datetime

# Modelo para registro de usuario
class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    confirm_password: str
    
    @validator('username')
    def username_alphanumeric(cls, v):
        if not v.isalnum():
            raise ValueError('El usuario debe contener solo letras y números')
        if len(v) < 3:
            raise ValueError('El usuario debe tener al menos 3 caracteres')
        return v
    
    @validator('confirm_password')
    def passwords_match(cls, v, values):
        if 'password' in values and v != values['password']:
            raise ValueError('Las contraseñas no coinciden')
        return v
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError('La contraseña debe tener al menos 6 caracteres')
        return v

# Modelo para login
class UserLogin(BaseModel):
    username: str
    password: str

# Modelo para respuesta de usuario (sin password)
class UserResponse(BaseModel):
    id: int
    username: str
    email: str
    rol: str
    activo: bool
    fecha_creacion: datetime
    
    class Config:
        from_attributes = True
        orm_mode = True  

# Modelo para token JWT
class Token(BaseModel):
    access_token: str
    token_type: str
    user: UserResponse


# Modelo para crear usuario desde admin (sin confirm_password)
class UserCreateAdmin(BaseModel):
    username: str
    email: str
    password: str
    rol: str = "operador"
    activo: bool = True
    
    @validator('username')
    def username_alphanumeric(cls, v):
        if not v.isalnum():
            raise ValueError('El usuario debe contener solo letras y números')
        if len(v) < 3:
            raise ValueError('El usuario debe tener al menos 3 caracteres')
        return v
    
    @validator('password')
    def password_strength(cls, v):
        if len(v) < 6:
            raise ValueError('La contraseña debe tener al menos 6 caracteres')
        return v

# Modelo para actualizar usuario
class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[str] = None
    rol: Optional[str] = None
    activo: Optional[bool] = None
    password: Optional[str] = None  # Para cambio de password desde admin
    
    @validator('username', pre=True, always=True)
    def username_alphanumeric(cls, v):
        if v is not None and v != "":
            if not v.isalnum():
                raise ValueError('El usuario debe contener solo letras y números')
            if len(v) < 3:
                raise ValueError('El usuario debe tener al menos 3 caracteres')
        return v
    
    @validator('password')
    def password_strength(cls, v):
        if v is not None and v != "":
            if len(v) < 6:
                raise ValueError('La contraseña debe tener al menos 6 caracteres')
        return v

# Modelo para cambio de contrase?a
class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str


# Modelo para actualizar datos del usuario actual
class UserSelfUpdate(BaseModel):
    email: str
    current_password: str
