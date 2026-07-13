/* Creacion de base de datos */
CREATE DATABASE tienda_db;

-- FUNCIÓN Y TRIGGERS PARA FECHA_ACTUALIZACION AUTOMÁTICA 

-- Esta función actualiza el campo 'fecha_actualizacion' con el momento exacto del cambio.
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tabla 1: usuarios

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY, 
    nombre VARCHAR(100) NOT NULL, 
    apellido VARCHAR(100) NOT NULL, 
    email VARCHAR(150) UNIQUE NOT NULL, 
    telefono VARCHAR(20), 
    fecha_nacimiento DATE, 
    activo BOOLEAN NOT NULL DEFAULT TRUE, 
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

-- Asignamos el trigger a la tabla usuarios 
CREATE TRIGGER trigger_actualizar_usuarios
BEFORE UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Tabla 2: productos

CREATE TABLE productos (
    id SERIAL PRIMARY KEY, 
    nombre VARCHAR(150) NOT NULL, 
    descripcion TEXT, 
    precio NUMERIC(10, 2) NOT NULL CHECK (precio >= 0), 
    stock INT NOT NULL CHECK (stock >= 0), 
    categoria VARCHAR(100),
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP 
);

-- Asignamos el trigger a la tabla productos 
CREATE TRIGGER trigger_actualizar_productos
BEFORE UPDATE ON productos
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Tabla 3: compras

-- Primero creamos un tipo ENUM para controlar estrictamente los estados permitidos [cite: 26]
CREATE TYPE estado_compra AS ENUM ('pendiente', 'pagada', 'enviada', 'cancelada');

CREATE TABLE compras (
    id SERIAL PRIMARY KEY, 
    usuario_id INT NOT NULL, 
    producto_id INT NOT NULL, 
    cantidad INT NOT NULL CHECK (cantidad > 0), 
    precio_unitario NUMERIC(10, 2) NOT NULL CHECK (precio_unitario >= 0), 
    total NUMERIC(10, 2) NOT NULL CHECK (total >= 0), 
    estado estado_compra NOT NULL DEFAULT 'pendiente',
    fecha_creacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    fecha_actualizacion TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, 

    CONSTRAINT fk_compras_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_compras_producto FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
);

-- Asignamos el trigger a la tabla compras 
CREATE TRIGGER trigger_actualizar_compras
BEFORE UPDATE ON compras
FOR EACH ROW
EXECUTE FUNCTION actualizar_fecha_modificacion();