CREATE DATABASE DB_SIGERD
GO

USE DB_SIGERD
GO

CREATE SCHEMA Seguridad;
GO

CREATE SCHEMA Ubicacion;
GO

CREATE SCHEMA Inventario;
GO

CREATE SCHEMA Envios;
GO

CREATE SCHEMA Recepciones;
GO

CREATE SCHEMA Auditoria;
GO

CREATE TABLE [Seguridad].[Roles]
(
	idRol INT IDENTITY(1,1) PRIMARY KEY,
	nombreRol VARCHAR(50) NOT NULL,
	descripcion VARCHAR(150)
);

CREATE TABLE [Seguridad].[Usuarios]
(
	idUsuario INT IDENTITY(1,1) PRIMARY KEY,
	nombreCompleto VARCHAR(150) NOT NULL,
	correo VARCHAR(100) UNIQUE NOT NULL,
	clave VARCHAR(255) NOT NULL,
	idRolUsuario INT REFERENCES [Seguridad].[Roles](idRol) NOT NULL,
	estado BIT DEFAULT 1
)

CREATE TABLE [Ubicacion].[Departamentos]
(
	idDepartamentos INT IDENTITY(1,1) PRIMARY KEY,
	nombreDepartamento VARCHAR(100) NOT NULL
)

CREATE TABLE [Ubicacion].[Delegaciones]
(
	idDelegacion INT IDENTITY(1,1) PRIMARY KEY,
	nombreDelegacion VARCHAR(150) NOT NULL,
	direccion VARCHAR(200) NOT NULL,
	telefono VARCHAR(20) NULL,
	idDepartamentoDelegaciones INT REFERENCES [Ubicacion].[Departamentos](idDepartamentos) NOT NULL
)

CREATE TABLE [Inventario].[Categorias]
(
	idCategoria INT IDENTITY(1,1) PRIMARY KEY,
	nombreCategoria VARCHAR(100) NOT NULL
)

CREATE TABLE [Inventario].[Articulos]
(
	idArticulo INT IDENTITY(1,1) PRIMARY KEY,
	nombreArticulo VARCHAR(150) NOT NULL,
	descripcion VARCHAR(200) NULL,
	idCategoriaArticulo INT REFERENCES [Inventario].[Categorias](idCategoria) NOT NULL
)

CREATE TABLE [Envios].[EstadoEnvios]
(
	idEstadoEnvio INT IDENTITY(1,1) PRIMARY KEY,
	nombreEstadoEnvio VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
)

CREATE TABLE [Envios].[Envios]
(
	idEnvio INT IDENTITY(1,1) PRIMARY KEY,
	codigoEnvio VARCHAR(30) UNIQUE NOT NULL,
	fechaEnvio DATETIME NOT NULL,
	idDelegacionEnvio INT REFERENCES [Ubicacion].[Delegaciones](idDelegacion) NOT NULL,
	idUsuarioEnvio INT REFERENCES [Seguridad].[Usuarios](idUsuario) NOT NULL,
	idEstadoEnvioEnvio INT REFERENCES [Envios].[EstadoEnvios](idEstadoEnvio) NOT NULL,
	observaciones VARCHAR(300)
)

CREATE TABLE [Envios].[DetalleEnvio]
(
	idDetalle INT IDENTITY(1,1) PRIMARY KEY,
	idEnvioDetalleEnvio INT REFERENCES [Envios].[Envios](idEnvio) NOT NULL,
	idArticuloDetalleEnvio INT REFERENCES [Inventario].[Articulos](idArticulo) NOT NULL,
	cantidad INT NOT NULL
)

CREATE TABLE [Recepciones].[Recepciones]
(
	idRecepcion INT IDENTITY(1,1) PRIMARY KEY,
	idEnvioRecepcion INT UNIQUE REFERENCES [Envios].[Envios](idEnvio) NOT NULL,
	fechaRecepcion DATETIME NOT NULL,
	idUsuarioRecepcion INT REFERENCES [Seguridad].[Usuarios](idUsuario) NOT NULL,
	observaciones VARCHAR(300)
)

CREATE TABLE [Auditoria].[TipoMovimientos]
(
	idTipoMovimiento INT IDENTITY(1,1) PRIMARY KEY,
	nombreMovimiento VARCHAR(50) NOT NULL,
	descripcion VARCHAR(200)
)

CREATE TABLE [Auditoria].[HistorialMovimientos]
(
	idHistorialMovimiento INT IDENTITY(1,1) PRIMARY KEY,
	idEnvioHistorialMovimiento INT REFERENCES [Envios].[Envios](idEnvio) NOT NULL,
	idTipoMovimientoHistorialMovimiento INT REFERENCES [Auditoria].[TipoMovimientos](idTipoMovimiento) NOT NULL,
	idEstadoEnvioHistorialMovimiento INT REFERENCES [Envios].[EstadoEnvios](idEstadoEnvio) NOT NULL,
	fechaMovimiento DATETIME NOT NULL,
	idUsuarioHistorialMovimiento INT REFERENCES [Seguridad].[Usuarios](idUsuario) NOT NULL,
	observaciones VARCHAR(300)
)


