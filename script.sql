-- Creacion de base de datos 
-- CREATE DATABASE tienda_db;

-- Creamos la conexion con la base de datos 
\c tienda_db

-- FUNCIÓN Y TRIGGERS PARA FECHA_ACTUALIZACION AUTOMÁTICA 

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

-- Insert Tabla usuarios

INSERT INTO usuarios (nombre, apellido, email, telefono, fecha_nacimiento) VALUES
('Oscar', 'Torres', 'oscar.torres@gmail.com', '4146567912', '2006-08-08'),
('Amanda', 'Martinez', 'amanda.martinez@gmail.com', '4123457121', '2000-12-12'),
('Juan', 'Rodriguez', 'juan.rodriguez@outlook.com', '4167789087', '2006-03-07'),
('Sofía', 'Castillo', 'sofia.castillo@gmail.com', '4142233445', '1999-07-21'),
('Diego', 'Ramirez', 'diego.ramirez@gmail.com', '4145566778', '2001-09-05'),
('Valeria', 'López', 'valeria.lopez@gmail.com', '4147788990', '1998-02-14'),
('Miguel', 'Herrera', 'miguel.herrera@outlook.com', '4146677889', '2002-11-09'),
('Fernanda', 'Gómez', 'fernanda.gomez@gmail.com', '4145566771', '2004-04-18'),
('Alejandro', 'Santos', 'alejandro.santos@gmail.com', '4143344556', '1997-06-30'),
('Paula', 'Mendoza', 'paula.mendoza@gmail.com', '4141122334', '2003-10-25');

-- Insert Tabla productos

INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Laptop Pro 15', 'Computadora portátil de alta gama con 16GB RAM', 1200.00, 15, 'Electrónica'),
('Smartphone X', 'Teléfono inteligente con pantalla OLED y 128GB', 799.99, 25, 'Electrónica'),
('Auriculares Bluetooth', 'Auriculares inalámbricos con cancelación de ruido', 150.00, 50, 'Electrónica'),
('Monitor 4K 27"', 'Monitor ultra HD ideal para diseño y gaming', 350.00, 8, 'Electrónica'),
('Teclado Mecánico', 'Teclado retroiluminado con switches de respuesta rápida', 85.50, 30, 'Electrónica'),
('Silla Ergonómica', 'Silla de escritorio ajustable para largas jornadas', 210.00, 12, 'Oficina'),
('Escritorio Elevable', 'Escritorio con motor para trabajar de pie o sentado', 450.00, 5, 'Oficina'),
('Cafetera de Goteo', 'Cafetera automática con filtro lavable y jarra de vidrio', 45.00, 20, 'Hogar'),
('Lámpara de Escritorio LED', 'Lámpara con regulador de intensidad y puerto USB', 25.99, 40, 'Hogar'),
('Aspiradora Robot', 'Aspiradora inteligente con mapeo láser para el hogar', 299.00, 0, 'Hogar');

-- Insert Tabla compras

INSERT INTO compras (usuario_id, producto_id, cantidad, precio_unitario, total, estado) VALUES
(1, 3, 2, 150.00, 300.00, 'pagada'),        
(2, 1, 1, 1200.00, 1200.00, 'enviada'),     
(3, 5, 1, 85.50, 85.50, 'pendiente'),       
(4, 9, 3, 25.99, 77.97, 'pagada'),          
(5, 6, 1, 210.00, 210.00, 'cancelada'),     
(6, 8, 2, 45.00, 90.00, 'pagada'),          
(7, 2, 1, 799.99, 799.99, 'enviada'),       
(8, 4, 1, 350.00, 350.00, 'pendiente'),     
(9, 3, 1, 150.00, 150.00, 'pagada'),        
(1, 9, 1, 25.99, 25.99, 'cancelada');       