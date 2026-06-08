
-- 1. TABLA: usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(20) DEFAULT 'operador',
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_login TIMESTAMP
);

-- 2. TABLA: dispositivos
CREATE TABLE dispositivos (
    id SERIAL PRIMARY KEY,
    usuario_id INTEGER REFERENCES usuarios(id),
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(200),
    fecha_instalacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

-- 3. TABLA: sensores
CREATE TABLE sensores (
    id SERIAL PRIMARY KEY,
    dispositivo_id INTEGER REFERENCES dispositivos(id),
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    unidad VARCHAR(20) NOT NULL,
    rango_min FLOAT,
    rango_max FLOAT,
    calibracion JSONB,
    activo BOOLEAN DEFAULT TRUE
);

-- 4. TABLA: mediciones
CREATE TABLE mediciones (
    id SERIAL PRIMARY KEY,
    sensor_id INTEGER REFERENCES sensores(id),
    valor FLOAT NOT NULL,
    calidad VARCHAR(20) DEFAULT 'buena',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. TABLA: estado_sistema
CREATE TABLE estado_sistema (
    id SERIAL PRIMARY KEY,
    dispositivo_id INTEGER REFERENCES dispositivos(id),
    bateria FLOAT,
    almacenamiento FLOAT,
    estado_conexion BOOLEAN DEFAULT TRUE,
    uptime INTEGER,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABLA: eventos_sistema
CREATE TABLE eventos_sistema (
    id SERIAL PRIMARY KEY,
    dispositivo_id INTEGER REFERENCES dispositivos(id),
    tipo VARCHAR(20) NOT NULL,
    severidad VARCHAR(10) NOT NULL,
    mensaje TEXT NOT NULL,
    resuelto BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ÍNDICES para mejor performance
CREATE INDEX idx_mediciones_sensor_id ON mediciones(sensor_id);
CREATE INDEX idx_mediciones_timestamp ON mediciones(timestamp);
CREATE INDEX idx_sensores_dispositivo_id ON sensores(dispositivo_id);
CREATE INDEX idx_estado_sistema_dispositivo_id ON estado_sistema(dispositivo_id);
CREATE INDEX idx_eventos_dispositivo_id ON eventos_sistema(dispositivo_id);
CREATE INDEX idx_eventos_timestamp ON eventos_sistema(timestamp);

-- DATOS INICIALES

-- 1. Usuario administrador por defecto
INSERT INTO usuarios (username, email, password_hash, rol) 
VALUES ('admin', 'admin@sensores.com', 'hashed_password_here', 'admin');

-- 2. Dispositivo principal (Waspmote)
INSERT INTO dispositivos (usuario_id, nombre, tipo, descripcion, ubicacion) 
VALUES (1, 'Waspmote Principal', 'Waspmote', 'Dispositivo principal de monitoreo', 'Laboratorio UIS');

-- 3. Sensores configurados
INSERT INTO sensores (dispositivo_id, nombre, tipo, unidad, rango_min, rango_max) VALUES
(1, 'SHT75 - Temperatura', 'temperatura', '°C', -40, 80),
(1, 'SHT75 - Humedad', 'humedad', '%', 0, 100),
(1, 'LDR - Luminosidad', 'luminosidad', 'RAW', 0, 1023),
(1, 'Watermark - Humedad Suelo', 'humedad_suelo', '%', 0, 100);

-- 4. Evento inicial del sistema
INSERT INTO eventos_sistema (dispositivo_id, tipo, severidad, mensaje) 
VALUES (1, 'info', 'baja', 'Sistema inicializado correctamente');