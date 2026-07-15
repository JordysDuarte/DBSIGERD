SELECT *
FROM [Seguridad].[Usuarios]


SELECT *
FROM [ubicacion].[Delegaciones]

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
	'Delegacion Masaya',
	'Masaya',
	NULL,
	2
)



--CAMPOS AGREGADOS A LAS TABLAS
EXEC sp_rename 'Ubicacion.Delegaciones.idDepartamentoDelegaciones', 'idDepartamentoDelegacion', 'COLUMN';

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