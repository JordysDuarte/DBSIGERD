SELECT 
	idUsuario,
	nombreCompleto,
	correo,
	nombreUsuario,
	claveHash,
	nombreRol,
	CASE
		WHEN estado = 1 THEN 'Activo'
		WHEN estado = 0 THEN 'Inactivo'
	END,
	debeCambiarClave,
	fechaUltimoCambioClave,  
	versionSeguridad
FROM [Seguridad].[Usuarios]
	INNER JOIN [Seguridad].[Roles]
	ON idRolUsuario = idRol
--WHERE estado = 0;


SELECT *
FROM [Envios].[Envios]

SELECT *
FROM [ubicacion].[Delegaciones]

SELECT *
FROM [Envios].EstadoEnvios

UPDATE [Seguridad].[Roles]
SET nombreRol = 'Super Administrador'
WHERE idRol = 1;

INSERT INTO [Seguridad].[Roles] 
(
	nombreRol,
	descripcion
)
VALUES
(
	'Usuario',
	'Tiene acceso a ciertos módulos específicos'
)


INSERT INTO [ubicacion].[Departamentos] 
(
	nombreDepartamento
)
VALUES 
('Managua'),
('Masaya'),
('Leon'),
('Chinandega'),
('Rivas'),
('Granada'),
('Esteli')

SELECT * FROM [ubicacion].[Departamentos]
SELECT * FROM [ubicacion].[Delegaciones]


INSERT INTO [ubicacion].[Delegaciones] 
(
	nombreDelegacion,
	direccion,
	telefono,
	idDepartamentoDelegaciones
)
VALUES
(
	'Sede Central',
	'Managua',
	NULL,
	1
),
(
	'Managua Oriental',
	'Managua',
	NULL,
	1
),
(
	'Managua Occidental',
	'Managua',
	NULL,
	1
),
(
	'Delegación Masaya',
	'Masaya',
	NULL,
	2
)




--CAMPOS AGREGADOS A LAS TABLAS
EXEC sp_rename 'Envios.Envios.idDelegacionEnvio', 'idDelegacionOrigenEnvio', 'COLUMN';

SELECT *
FROM Envios.Envios

ALTER TABLE Envios.Envios
ADD idDelegacionDestinoEnvio INT NOT NULL;

ALTER TABLE Seguridad.Usuarios
ALTER COLUMN claveHash VARCHAR(512) NOT NULL;

ALTER TABLE Seguridad.Usuarios
ADD nombreUsuario VARCHAR(50) NULL;
GO

ALTER TABLE Seguridad.Usuarios
ADD idDelegacionUsuario INT NULL;
GO

ALTER TABLE Seguridad.Usuarios
ADD debeCambiarClave BIT NOT NULL
CONSTRAINT DF_Usuarios_debeCambiarClave DEFAULT(1);
GO

ALTER TABLE Seguridad.Usuarios
ADD fechaUltimoCambioClave DATETIME2 NULL;
GO

ALTER TABLE Seguridad.Usuarios
ADD versionSeguridad UNIQUEIDENTIFIER NOT NULL
CONSTRAINT DF_Usuarios_versionSeguridad DEFAULT NEWID();
GO

UPDATE Seguridad.Usuarios
SET nombreUsuario = CONCAT('usuario', idUsuario)
WHERE nombreUsuario IS NULL;
GO

UPDATE Seguridad.Usuarios
SET idDelegacionUsuario = (
	SELECT TOP 1 idDelegacion
	FROM Ubicacion.Delegaciones
	ORDER BY idDelegacion
	)
	WHERE idDelegacionUsuario IS NULL;
	GO

ALTER TABLE Seguridad.Usuarios
ALTER COLUMN nombreUsuario VARCHAR(50) NOT NULL;
GO

ALTER TABLE Seguridad.Usuarios
ALTER COLUMN idDelegacionUsuario INT NOT NULL;

CREATE UNIQUE INDEX UX_Usuarios_NombreUsuario
ON Seguridad.Usuarios(nombreUsuario);
GO

ALTER TABLE Seguridad.Usuarios
ADD CONSTRAINT FK_Usuarios_Delegaciones_idDelegacionUsuario
FOREIGN KEY (idDelegacionUsuario)
REFERENCES Ubicacion.Delegaciones(idDelegacion);
GO


ALTER TABLE Ubicacion.Delegaciones
ALTER COLUMN idDepartamentoDelegacion INT NOT NULL;

SELECT 
	idUsuario,
	nombreCompleto,
	correo,
	nombreDelegacion,
	idDelegacionUsuario
FROM [Seguridad].[Usuarios] U
INNER JOIN 
	[Ubicacion].[Delegaciones] D
ON
	U.idDelegacionUsuario = D.idDelegacion
	


	SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Ubicacion'
  AND TABLE_NAME = 'Delegaciones'
ORDER BY ORDINAL_POSITION;

SELECT 
    d.idDelegacion,
    d.nombreDelegacion,
    d.idDepartamentoDelegacion
FROM Ubicacion.Delegaciones d;


SELECT 
    d.idDelegacion,
    d.nombreDelegacion,
    d.idDepartamentoDelegacion
FROM Ubicacion.Delegaciones d
WHERE d.idDepartamentoDelegacion IS NULL;


SELECT 
    idUsuario,
    nombreCompleto,
    nombreUsuario,
    correo,
    estado,
    debeCambiarClave
FROM Seguridad.Usuarios;

SELECT 
    idUsuario,
    nombreCompleto,
    nombreUsuario,
    correo,
    claveHash,
    estado,
    debeCambiarClave,
    idRolUsuario,
    idDelegacionUsuario,
    versionSeguridad
FROM Seguridad.Usuarios;


SELECT 
    nombreUsuario,
    claveHash,
    debeCambiarClave,
    fechaUltimoCambioClave,
    versionSeguridad
FROM Seguridad.Usuarios
WHERE nombreUsuario = 'admin';



SELECT 
    idUsuario,
    nombreCompleto,
    nombreUsuario,
    correo,
    LEN(claveHash) AS LongitudHash,
    LEFT(claveHash, 20) AS InicioHash,
    estado,
    debeCambiarClave,
    fechaUltimoCambioClave
FROM Seguridad.Usuarios
WHERE nombreUsuario = 'admin';



BEGIN TRANSACTION;

DECLARE @NombreFK NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

SELECT TOP 1 
    @NombreFK = fk.name
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
WHERE fk.parent_object_id = OBJECT_ID('Envios.Envios')
  AND COL_NAME(fkc.parent_object_id, fkc.parent_column_id) = 'idDelegacionEnvio';

IF @NombreFK IS NOT NULL
BEGIN
    SET @SQL = 'ALTER TABLE Envios.Envios DROP CONSTRAINT ' + QUOTENAME(@NombreFK);
    EXEC sp_executesql @SQL;
END;

IF COL_LENGTH('Envios.Envios', 'idDelegacionDestinoEnvio') IS NULL
   AND COL_LENGTH('Envios.Envios', 'idDelegacionEnvio') IS NOT NULL
BEGIN
    EXEC sp_rename 
        'Envios.Envios.idDelegacionEnvio',
        'idDelegacionDestinoEnvio',
        'COLUMN';
END;

IF COL_LENGTH('Envios.Envios', 'idDelegacionOrigenEnvio') IS NULL
BEGIN
    ALTER TABLE Envios.Envios
    ADD idDelegacionOrigenEnvio INT NULL;
END;

DECLARE @DelegacionDefault INT;

SELECT TOP 1 
    @DelegacionDefault = idDelegacion
FROM Ubicacion.Delegaciones
ORDER BY idDelegacion;

UPDATE Envios.Envios
SET idDelegacionOrigenEnvio = ISNULL(idDelegacionOrigenEnvio, @DelegacionDefault)
WHERE idDelegacionOrigenEnvio IS NULL;

ALTER TABLE Envios.Envios
ALTER COLUMN idDelegacionOrigenEnvio INT NOT NULL;

ALTER TABLE Envios.Envios
ALTER COLUMN idDelegacionDestinoEnvio INT NOT NULL;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Envios_Delegaciones_Origen'
)
BEGIN
    ALTER TABLE Envios.Envios
    ADD CONSTRAINT FK_Envios_Delegaciones_Origen
    FOREIGN KEY (idDelegacionOrigenEnvio)
    REFERENCES Ubicacion.Delegaciones(idDelegacion);
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_Envios_Delegaciones_Destino'
)
BEGIN
    ALTER TABLE Envios.Envios
    ADD CONSTRAINT FK_Envios_Delegaciones_Destino
    FOREIGN KEY (idDelegacionDestinoEnvio)
    REFERENCES Ubicacion.Delegaciones(idDelegacion);
END;

COMMIT TRANSACTION;


SELECT *
FROM [Inventario].[Categorias]


BEGIN TRANSACTION;

DECLARE @IdCategoriaGeneral INT;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Categorias
    WHERE nombreCategoria = 'General'
)
BEGIN
    INSERT INTO Inventario.Categorias
    (
        nombreCategoria
    )
    VALUES
    (
        'General'
    );
END;

SELECT @IdCategoriaGeneral = idCategoria
FROM Inventario.Categorias
WHERE nombreCategoria = 'General';

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'Impresora'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'Impresora',
        'Impresora institucional para envío entre delegaciones.',
        @IdCategoriaGeneral
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'Monitor'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'Monitor',
        'Monitor para equipo de oficina.',
        @IdCategoriaGeneral
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'CPU'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'CPU',
        'Unidad central de procesamiento para puesto de trabajo.',
        @IdCategoriaGeneral
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'Teclado'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'Teclado',
        'Teclado para equipo de cómputo.',
        @IdCategoriaGeneral
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'Mouse'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'Mouse',
        'Mouse para equipo de cómputo.',
        @IdCategoriaGeneral
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM Inventario.Articulos
    WHERE nombreArticulo = 'Switch de red'
)
BEGIN
    INSERT INTO Inventario.Articulos
    (
        nombreArticulo,
        descripcion,
        idCategoriaArticulo
    )
    VALUES
    (
        'Switch de red',
        'Switch utilizado para conexión de red institucional.',
        @IdCategoriaGeneral
    );
END;

COMMIT TRANSACTION;


SELECT *
FROM [Inventario].[Categorias]

SELECT *
FROM [Inventario].[Articulos]


BEGIN TRANSACTION;

IF NOT EXISTS (
    SELECT 1 
    FROM Envios.EstadoEnvios 
    WHERE nombreEstadoEnvio = 'Pendiente'
)
BEGIN
    INSERT INTO Envios.EstadoEnvios
    (
        nombreEstadoEnvio,
        descripcion
    )
    VALUES
    (
        'Pendiente',
        'El envío fue registrado, pero aún no ha sido recibido.'
    );
END;

IF NOT EXISTS (
    SELECT 1 
    FROM Envios.EstadoEnvios
    WHERE nombreEstadoEnvio = 'En tránsito'
)
BEGIN
    INSERT INTO Envios.EstadoEnvios
    (
        nombreEstadoEnvio,
        descripcion
    )
    VALUES
    (
        'En tránsito',
        'El envío se encuentra en proceso de traslado.'
    );
END;

IF NOT EXISTS (
    SELECT 1 
    FROM Envios.EstadoEnvios 
    WHERE nombreEstadoEnvio = 'Recibido'
)
BEGIN
    INSERT INTO Envios.EstadoEnvios
    (
        nombreEstadoEnvio,
        descripcion
    )
    VALUES
    (
        'Recibido',
        'El envío fue recibido correctamente en la delegación destino.'
    );
END;

IF NOT EXISTS (
    SELECT 1 
    FROM Envios.EstadoEnvios 
    WHERE nombreEstadoEnvio = 'Cancelado'
)
BEGIN
    INSERT INTO Envios.EstadoEnvios
    (
        nombreEstadoEnvio,
        descripcion
    )
    VALUES
    (
        'Cancelado',
        'El envío fue cancelado antes de ser recibido.'
    );
END;

IF NOT EXISTS (
    SELECT 1 
    FROM Envios.EstadoEnvios
    WHERE nombreEstadoEnvio = 'Extraviado'
)
BEGIN
    INSERT INTO Envios.EstadoEnvios
    (
        nombreEstadoEnvio,
        descripcion
    )
    VALUES
    (
        'Extraviado',
        'El envío fue reportado como extraviado.'
    );
END;

COMMIT TRANSACTION;


SELECT *
FROM [Envios].[Envios] AS e
    INNER JOIN [Envios].[DetalleEnvio] AS d
    ON e.idEnvio = d.idEnvioDetalleEnvio
    INNER JOIN [Inventario].[Articulos] AS a
    ON d.idArticuloDetalleEnvio = a.idArticulo
WHERE codigoEnvio LIKE '%002'


SELECT 
    nombreUsuario,
    nombreRol,
    descripcion
FROM [Seguridad].Usuarios AS u
INNER JOIN [Seguridad].[Roles] AS r
    ON u.idRolUsuario = r.idRol
WHERE nombreUsuario = 'djduarte';


IF COL_LENGTH('Envios.DetalleEnvio', 'observacionesDetalleEnvio') IS NULL
BEGIN
    ALTER TABLE Envios.DetalleEnvio
    ADD observacionesDetalleEnvio VARCHAR(500) NULL;
END;