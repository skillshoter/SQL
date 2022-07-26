USE [BANCO]
GO

IF NOT EXISTS
(
	SELECT
		1
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		UPPER(TABLE_NAME) = UPPER('log_arquivos')
		AND UPPER(COLUMN_NAME) = UPPER('processado')
)
BEGIN
	ALTER TABLE DBO.log_arquivos
	ADD processado BIT DEFAULT 0 NOT NULL
END
GO


IF NOT EXISTS
(
	SELECT
		1
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		UPPER(TABLE_NAME) = UPPER('log_sessao')
		AND UPPER(COLUMN_NAME) = UPPER('processado')
)
BEGIN
	ALTER TABLE DBO.log_sessao
	ADD processado BIT DEFAULT 0 NOT NULL
END
GO


IF NOT EXISTS
(
	SELECT
		1
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		UPPER(TABLE_NAME) = UPPER('log_acesso')
		AND UPPER(COLUMN_NAME) = UPPER('processado')
)
BEGIN
	ALTER TABLE DBO.log_acesso
	ADD processado BIT DEFAULT 0 NOT NULL
END
GO




IF NOT EXISTS
(
	SELECT
		1
	FROM
		INFORMATION_SCHEMA.COLUMNS
	WHERE
		UPPER(TABLE_NAME) = UPPER('log_out_system')
		AND UPPER(COLUMN_NAME) = UPPER('processado')
)
BEGIN
	ALTER TABLE DBO.log_out_system
	ADD processado BIT DEFAULT 0 NOT NULL
END
GO
