# sigma_api/app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from datetime import timedelta

from app.database import get_db
from app.models.database_models import Usuario
from app.models.user_models import UserCreate, UserLogin, Token, UserResponse, UserCreateAdmin, UserUpdate, ChangePasswordRequest, UserSelfUpdate
from app.utils.auth_utils import (
    verify_password, 
    get_password_hash, 
    create_access_token,
    verify_token
)
from app.config import settings
from app.dependencies import get_current_active_admin

router = APIRouter(prefix="/api/auth", tags=["Autenticación"])
security = HTTPBearer()

@router.post("/register", response_model=Token)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Registrar nuevo usuario"""
    
    # Verificar si ya existe usuario con ese username
    existing_user = db.query(Usuario).filter(
        (Usuario.username == user_data.username) | 
        (Usuario.email == user_data.email)
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Usuario o email ya registrado"
        )
    
    # Verificar si es el primer usuario (se convierte en admin)
    user_count = db.query(Usuario).count()
    rol = "admin" if user_count == 0 else "operador"
    
    # Crear nuevo usuario
    new_user = Usuario(
        username=user_data.username,
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        rol=rol,
        activo=True
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Crear token JWT
    access_token = create_access_token(
        data={"user_id": new_user.id, "username": new_user.username, "rol": new_user.rol}
    )
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse.from_orm(new_user)
    )

@router.post("/login", response_model=Token)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    """Iniciar sesión"""
    
    # Buscar usuario por username
    user = db.query(Usuario).filter(Usuario.username == login_data.username).first()
    
    if not user or not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos"
        )
    
    # Verificar password
    if not verify_password(login_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos"
        )
    
    # Crear token JWT
    access_token = create_access_token(
        data={"user_id": user.id, "username": user.username, "rol": user.rol}
    )
    
    # Actualizar último login
    from datetime import datetime
    user.ultimo_login = datetime.utcnow()
    db.commit()
    
    return Token(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse.from_orm(user)
    )

@router.get("/me", response_model=UserResponse)
def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Obtener información del usuario actual"""
    token = credentials.credentials
    payload = verify_token(token)
    
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido o expirado"
        )
    
    user = db.query(Usuario).filter(Usuario.id == payload.get("user_id")).first()
    
    if not user or not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado"
        )
    
    return UserResponse.from_orm(user)


@router.put("/me", response_model=UserResponse)
def update_current_user(
    user_data: UserSelfUpdate,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Actualizar datos del usuario actual (email)"""
    token = credentials.credentials
    payload = verify_token(token)
    
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token invÃ¡lido o expirado"
        )
    
    user = db.query(Usuario).filter(Usuario.id == payload.get("user_id")).first()
    
    if not user or not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado"
        )
    
    # Verificar password actual
    if not verify_password(user_data.current_password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="ContraseÃ±a actual incorrecta"
        )
    
    # Verificar unicidad de email si se va a cambiar
    if user_data.email and user_data.email != user.email:
        existing_user = db.query(Usuario).filter(Usuario.email == user_data.email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email ya estÃ¡ en uso"
            )
    
    user.email = user_data.email
    db.commit()
    db.refresh(user)
    
    return UserResponse.from_orm(user)

@router.post("/change-password")
def change_password(
    payload: ChangePasswordRequest,
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
):
    """Cambiar contrase?a del usuario actual"""
    # Soportar payload como dict si el parser no crea el modelo
    if isinstance(payload, dict):
        current_password = payload.get("current_password")
        new_password = payload.get("new_password")
    else:
        current_password = payload.current_password
        new_password = payload.new_password

    if not current_password or not new_password:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="current_password y new_password son requeridos"
        )

    token = credentials.credentials
    payload = verify_token(token)

    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inv?lido o expirado"
        )

    user = db.query(Usuario).filter(Usuario.id == payload.get("user_id")).first()

    if not user or not user.activo:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado"
        )

    # Verificar password actual
    if not verify_password(current_password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Contrase?a actual incorrecta"
        )

    # Cambiar password
    user.password_hash = get_password_hash(new_password)
    db.commit()

    return {"message": "Contrase?a cambiada exitosamente"}


@router.get("/users", response_model=list[UserResponse])
def get_all_users(
    current_admin: Usuario = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    """
    Obtener todos los usuarios (solo administrador)
    """
    users = db.query(Usuario).order_by(Usuario.fecha_creacion.desc()).all()
    return users


@router.post("/users", response_model=UserResponse)
def create_user(
    user_data: UserCreateAdmin,
    current_admin: Usuario = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    """
    Crear nuevo usuario (solo administrador)
    """
    # Verificar si ya existe usuario con ese username o email
    existing_user = db.query(Usuario).filter(
        (Usuario.username == user_data.username) | 
        (Usuario.email == user_data.email)
    ).first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Usuario o email ya registrado"
        )
    
    # Crear nuevo usuario
    new_user = Usuario(
        username=user_data.username,
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        rol=user_data.rol,
        activo=user_data.activo
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return UserResponse.from_orm(new_user)


@router.put("/users/{user_id}", response_model=UserResponse)
def update_user(
    user_id: int,
    user_data: UserUpdate,
    current_admin: Usuario = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    """
    Actualizar usuario (solo administrador)
    """
    # Buscar usuario a actualizar
    user = db.query(Usuario).filter(Usuario.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    # Verificar unicidad de username si se va a cambiar
    if user_data.username and user_data.username != user.username:
        existing_user = db.query(Usuario).filter(Usuario.username == user_data.username).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Username ya está en uso"
            )
    
    # Verificar unicidad de email si se va a cambiar
    if user_data.email and user_data.email != user.email:
        existing_user = db.query(Usuario).filter(Usuario.email == user_data.email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email ya está en uso"
            )
    
    # Actualizar campos
    if user_data.username is not None:
        user.username = user_data.username
    if user_data.email is not None:
        user.email = user_data.email
    if user_data.rol is not None:
        user.rol = user_data.rol
    if user_data.activo is not None:
        user.activo = user_data.activo
    if user_data.password is not None and user_data.password != "":
        user.password_hash = get_password_hash(user_data.password)
    
    db.commit()
    db.refresh(user)
    
    return UserResponse.from_orm(user)


@router.delete("/users/{user_id}")
def delete_user(
    user_id: int,
    current_admin: Usuario = Depends(get_current_active_admin),
    db: Session = Depends(get_db)
):
    """
    Desactivar usuario (solo administrador)
    Nota: No eliminamos físicamente, solo desactivamos
    """
    # Buscar usuario
    user = db.query(Usuario).filter(Usuario.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    # No permitir desactivarse a sí mismo
    if user.id == current_admin.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No puede desactivar su propia cuenta"
        )
    
    # Desactivar usuario
    user.activo = False
    db.commit()
    
    return {"message": f"Usuario {user.username} desactivado exitosamente"}
