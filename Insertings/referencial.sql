USE [banco]
GO

SET QUOTED_IDENTIFIER ON

BEGIN TRANSACTION
SET NOCOUNT ON
DECLARE
	@registro INT,
	@registro_total INT,
	@historico INT,
	@historico_total INT

SET @registro = 0
SET @registro_total = 0
SET @historico = 0
SET @historico_total = 0

IF OBJECT_ID('#tempTable') IS NOT NULL
	DROP TABLE #tempTable

CREATE TABLE #tempTable
(
	Cliente [VARCHAR](50) NOT NULL,
	[Empresa] [VARCHAR](50) NOT NULL,
	[Seq] [INT] NOT NULL,
	Descri [VARCHAR](MAX) NOT NULL
)

INSERT #tempTable
(
	Cliente,
	[Empresa],
	[Seq],
	Descri
)
VALUES
(
	'xxx',
	'xxx',
	1,
	'Inserção dos links de xxx ( politica de privacidade ) na tabela registro.'
)

SELECT
	@historico_total = COUNT(*)
FROM
	#tempTable TT
	LEFT JOIN tkgs_cap.DBO.historico GHS ON
		GHS.Cliente COLLATE SQL_Latin1_General_CP1_CI_AS = TT.Cliente COLLATE SQL_Latin1_General_CP1_CI_AS
		
WHERE
	GHS.[NUM_SEQ] IS NULL

SET @registro_total = 1

IF NOT EXISTS
(
	SELECT
		GDM.*
	FROM
		DBO.registro GDM
	WHERE
		GDM.codigo = 'identificador'
)
BEGIN
	INSERT INTO dbo.registro
	(
		codigo,
		dcr_domin,
		cod_sub_domin,
		dcr_sub_domin,
		nro_Seq,
		dta_incl,
		dta_alt,
		nom_usr_incl
	)
	VALUES
	(
		'identificador',
		'Link',
		'LK',
		CASE WHEN @@SERVERNAME = 'banco\HML' THEN 'site' WHEN @@SERVERNAME = 'banco\DEV' THEN 'site dev' ELSE 'site prod' END,
		'1',
		GETDATE(),
		GETDATE(),
		'ADMIN'
	)
	
	SET @registro = @registro + @@ROWCOUNT
END

INSERT tkgs_cap.DBO.historico
(
	Cliente,
	[Empresa],
	[Seq],
	Descri
)
(
	SELECT
		TT.Cliente,
		TT.[Empresa],
		TT.[Seq],
		TT.Descri
	FROM
		#tempTable TT
		LEFT JOIN tkgs_cap.DBO.historico GHS ON
			GHS.Cliente COLLATE SQL_Latin1_General_CP1_CI_AS = TT.Cliente COLLATE SQL_Latin1_General_CP1_CI_AS
			AND GHS.[Empresa] COLLATE SQL_Latin1_General_CP1_CI_AS = TT.[Empresa] COLLATE SQL_Latin1_General_CP1_CI_AS
			AND GHS.[Seq] = TT.[Seq]
	WHERE
		GHS.[NUM_SEQ] IS NULL
)

SET @historico = @historico + @@ROWCOUNT

IF @@ERROR = 0
BEGIN
	PRINT '************************** Inicio DE EXECUÇÃO **********************************************'
	PRINT 'Quantidade de registros atualizado na tabela registro		: ' + CONVERT(VARCHAR(20), @registro)	+ ' no total de : ' + CONVERT(VARCHAR(20),@registro_total)
	PRINT 'Quantidade de registros inseridos na tabela historico		: ' + CONVERT(VARCHAR(20), @historico)      + ' no total de : ' + CONVERT(VARCHAR(20), @historico_total)

	DECLARE
		@Executar BIT = 1
	
	IF @registro <> @registro_total
		SET @Executar = 0

	IF @historico <> @historico_total
		SET @Executar = 0

	IF @@SERVERNAME = 'banco\HML'
	BEGIN
		IF @Executar = 1
		BEGIN
			PRINT '*** Processo concluído com sucesso em HOMOLOGAÇÃO ***'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			PRINT '*** Erro ao executar o script em HOMOLOGAÇÃO - Quantidade de registros diferente do esperado ***'
			ROLLBACK TRANSACTION
		END
	END
	ELSE IF @@SERVERNAME = 'banco\DEV'
	BEGIN
		IF @Executar = 1
		BEGIN
			PRINT '*** Processo concluído com sucesso em DESENVOLVIMENTO ***'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			PRINT '*** Erro ao executar o script em HOMOLOGAÇÃO - Quantidade de registros diferente do esperado ***'
			ROLLBACK TRANSACTION
		END
	END
	ELSE
	BEGIN
		IF @Executar = 1
		BEGIN
			PRINT '*** Processo concluído com sucesso em PRODUÇÃO ***'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			PRINT '*** Erro ao executar o script em PRODUÇÃO - Quantidade de registros diferente do esperado ***'
			ROLLBACK TRANSACTION
		END
	END
END
ELSE
BEGIN
	ROLLBACK TRANSACTION
END
GO
