-- Creacion de base de datos 
 CREATE DATABASE tienda_db;

-- Creamos la conexion con la base de datos 
\c tienda_db

-- FUNCIÓN Y TRIGGERS PARA FECHA_ACTUALIZACION AUTOMaTICA 

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

/*-------------------------------------------------------------------------

-                            CARGA DE DATOS

-------------------------------------------------------------------------*/


-- Insert #1: Tabla usuarios

INSERT INTO usuarios (nombre, apellido, email, telefono, fecha_nacimiento) VALUES
('Oscar', 'Torres', 'oscar.torres@gmail.com', '4146567912', '2006-08-08'),
('Amanda', 'Martinez', 'amanda.martinez@gmail.com', '4123457121', '2000-12-12'),
('Juan', 'Rodriguez', 'juan.rodriguez@outlook.com', '4167789087', '2006-03-07'),
('Sofia', 'Castillo', 'sofia.castillo@gmail.com', '4142233445', '1999-07-21'),
('Diego', 'Ramirez', 'diego.ramirez@gmail.com', '4145566778', '2001-09-05'),
('Valeria', 'Lopez', 'valeria.lopez@gmail.com', '4147788990', '1998-02-14'),
('Miguel', 'Herrera', 'miguel.herrera@outlook.com', '4146677889', '2002-11-09'),
('Fernanda', 'Gomez', 'fernanda.gomez@gmail.com', '4145566771', '2004-04-18'),
('Alejandro', 'Santos', 'alejandro.santos@gmail.com', '4143344556', '1997-06-30'),
('Paula', 'Mendoza', 'paula.mendoza@gmail.com', '4141122334', '2003-10-25');

-- Insert #2: Tabla productos

INSERT INTO productos (nombre, descripcion, precio, stock, categoria) VALUES
('Laptop Pro 15', 'Computadora portatil de alta gama con 16GB RAM', 1200.00, 15, 'Electronica'),
('Smartphone X', 'Telefono inteligente con pantalla OLED y 128GB', 799.99, 25, 'Electronica'),
('Auriculares Bluetooth', 'Auriculares inalambricos con cancelacion de ruido', 150.00, 50, 'Electronica'),
('Monitor 4K 27"', 'Monitor ultra HD ideal para diseño y gaming', 350.00, 8, 'Electronica'),
('Teclado Mecanico', 'Teclado retroiluminado con switches de respuesta rapida', 85.50, 30, 'Electronica'),
('Silla Ergonomica', 'Silla de escritorio ajustable para largas jornadas', 210.00, 12, 'Oficina'),
('Escritorio Elevable', 'Escritorio con motor para trabajar de pie o sentado', 450.00, 5, 'Oficina'),
('Cafetera de Goteo', 'Cafetera automatica con filtro lavable y jarra de vidrio', 45.00, 20, 'Hogar'),
('Lampara de Escritorio LED', 'Lampara con regulador de intensidad y puerto USB', 25.99, 40, 'Hogar'),
('Aspiradora Robot', 'Aspiradora inteligente con mapeo laser para el hogar', 299.00, 0, 'Hogar');

-- Insert #3: Tabla compras

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

/*-------------------------------------------------------------------------

-                            CONSULTA DE BUSQUEDA

-------------------------------------------------------------------------*/

-- 3.1 Productos disponibles y económicos

SELECT nombre, categoria, precio, stock FROM productos WHERE precio<50 AND stock>=1;

-- 3.2 Los cinco productos más caros

SELECT nombre, precio FROM productos ORDER BY precio DESC LIMIT 5;

-- 3.3 Los cinco productos más caros

SELECT nombre ||''|| apellido AS nombre_complet0 FROM usuarios WHERE email LIKE'%@gmail.com' OR apellido like 'R%' ORDER BY apellido ASC;

-- 3.4 Historial de compras detallado


-- 3.5 Ranking de clientes

SELECT  u.nombre || ' ' || u.apellido AS nombre_completo, COUNT(c.id) AS cantidad_compras, SUM(c.total) AS total_gastad FROM usuarios  INNER JOIN compras c ON u.id = c.usuario_i WHERE c.estado != 'cancelada' GROUP BY u.id, u.nombre, u.apellid HAVING SUM(c.total) >= 10 ORDER BY total_gastado DESC;

/*-------------------------------------------------------------------------

-                            CONSULTA DE ACTUALIZACION

-------------------------------------------------------------------------*/

-- 4.1 Corrección de un dato puntual

UPDATE usuarios SET telefono = '4146406454' WHERE id = 3;

-- SELECT para verificar que el cambio se aplicó correctamente
SELECT id, nombre, apellido, telefono FROM usuarios WHERE id = 3;

--4.2 Ajuste de precios por categoría

UPDATE productos SET precio = precio * 1.15 WHERE categoria = 'Electronica' AND precio > 100;

-- SELECT para verificar que el cambio se aplicó correctamente
SELECT nombre, categoria, precio FROM productos WHERE precio> 100 AND categoria = 'Electronica';

--4.3 Depuración de clientes inactivos
UPDATE usuarios SET activo = false WHERE id NOT IN ( SELECT DISTINCT usuario_id  FROM compras );

-- SELECT para verificar qué usuarios quedaron inactivos
SELECT id, nombre, apellido, email, activo FROM usuarios WHERE activo = false;

