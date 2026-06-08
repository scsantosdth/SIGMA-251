from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, ForeignKey, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base

class Usuario(Base):
    __tablename__ = "usuarios"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    rol = Column(String(20), default='operador')
    activo = Column(Boolean, default=True)
    fecha_creacion = Column(DateTime, default=func.now())
    ultimo_login = Column(DateTime)

class Dispositivo(Base):
    __tablename__ = "dispositivos"
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey('usuarios.id'))
    nombre = Column(String(100), nullable=False)
    tipo = Column(String(50), nullable=False)
    descripcion = Column(Text)
    ubicacion = Column(String(200))
    fecha_instalacion = Column(DateTime, default=func.now())
    activo = Column(Boolean, default=True)

class Sensor(Base):
    __tablename__ = "sensores"
    id = Column(Integer, primary_key=True, index=True)
    dispositivo_id = Column(Integer, ForeignKey('dispositivos.id'))
    nombre = Column(String(100), nullable=False)
    tipo = Column(String(50), nullable=False)
    unidad = Column(String(20), nullable=False)
    rango_min = Column(Float)
    rango_max = Column(Float)
    calibracion = Column(String)  # JSON como string por simplicidad
    activo = Column(Boolean, default=True)

class Medicion(Base):
    __tablename__ = "mediciones"
    id = Column(Integer, primary_key=True, index=True)
    sensor_id = Column(Integer, ForeignKey('sensores.id'))
    valor = Column(Float, nullable=False)
    calidad = Column(String(20), default='buena')
    timestamp = Column(DateTime, default=func.now())

class EstadoSistema(Base):
    __tablename__ = "estado_sistema"
    id = Column(Integer, primary_key=True, index=True)
    dispositivo_id = Column(Integer, ForeignKey('dispositivos.id'))
    bateria = Column(Float)
    almacenamiento = Column(Float)
    estado_conexion = Column(Boolean, default=True)
    uptime = Column(Integer)
    timestamp = Column(DateTime, default=func.now())

class EventoSistema(Base):
    __tablename__ = "eventos_sistema"
    id = Column(Integer, primary_key=True, index=True)
    dispositivo_id = Column(Integer, ForeignKey('dispositivos.id'))
    tipo = Column(String(20), nullable=False)
    severidad = Column(String(10), nullable=False)
    mensaje = Column(Text, nullable=False)
    resuelto = Column(Boolean, default=False)
    timestamp = Column(DateTime, default=func.now())

class Configuracion(Base):
    __tablename__ = "configuracion"
    id = Column(Integer, primary_key=True, index=True)
    clave = Column(String(100), unique=True, nullable=False)
    valor = Column(String(500), nullable=False)
    descripcion = Column(Text, nullable=True)
    actualizado_en = Column(DateTime, default=func.now(), onupdate=func.now())