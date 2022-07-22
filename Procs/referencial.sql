USE [banco]
GO

IF OBJECT_ID('procedure_name') IS NULL
	EXEC sp_executesql @statement = N'CREATE PROCEDURE procedure_name AS SET NOCOUNT ON;'
GO

ALTER PROCEDURE [dbo].[procedure_name]
(
	@DATA_INCLUSAO DATE,
	@NrErro INT = 0 OUTPUT,
	@DscErro VARCHAR(255)  = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		BEGIN TRANSACTION
		
	DECLARE 
	@controle INT = 0
		
	SET @controle =	(SELECT 
	CASE WHEN count(*) > 1  THEN 1 ELSE 0 END 
	FROM [dbo].[table_central_logs] WHERE dat_inclusao < (SELECT convert(varchar(10), DateAdd(yy, -5, GetDate()),120)))
	
	IF (@controle = 1)
	BEGIN
		DELETE [dbo].[table_central_logs] WHERE dat_inclusao < (SELECT convert(varchar(10), DateAdd(yy, -5, GetDate()),120))
	END

	INSERT INTO [dbo].[table_central_logs]
           (
            [user_interacao]
           ,[id_user_acao]
           ,[user_acao_flg_inclui]
           ,[user_acao_flg_exclui]
           ,[user_acao_flg_altera]
           ,[user_acao_flg_consulta]
           ,[user_acao_flg_aprova]
           ,[dat_acao]
		   ,[dat_inclusao]
		   )
		   SELECT 
		   modulo.usu_mandatorio,
		   modulo.usu_mandatorio,
		   acao_perfil.flg_inclui,
		   acao_perfil.flg_exclui,
		   acao_perfil.flg_altera,
		   acao_perfil.flg_consulta,
		   acao_perfil.flg_aprova,
		   modulo.dat_acao_realizada,
		   GETDATE()
		   FROM dbo.log_ as modulo
		   INNER JOIN usuario as usu on modulo.usu_mandatorio = usu.cod_usr
		   INNER JOIN acao_perfil as acao_perfil on usu.cod_perf = acao_perfil.cod_perf
		   where modulo.processado = 0 and modulo.metodo = 'Produto - Alteração'
	
	INSERT INTO [dbo].[table_central_logs]
           (
            [oper_relevant_sist]
           ,[id_user_oper]
           ,[perfil_user_oper]
           ,[dat_oper]
           ,[cli_prod_oper]
		    ,[dat_inclusao]
		   )
		   SELECT 
		   modulo.acao_realizada,
		   modulo.usu_mandatorio,
		   perfil.dcr_perf,
		   modulo.dat_acao_realizada,
		   modulo.metodo,
		   GETDATE()
		   FROM dbo.log_modulo as modulo
		   INNER JOIN usuario as usu on modulo.usu_mandatorio = usu.cod_usr
		   INNER JOIN perfil as perfil on usu.cod_perf = perfil.cod_perf
		   where modulo.processado = 0 and modulo.metodo != 'Produto - Alteração'

		   UPDATE log_modulo set processado = 1 where processado = 0
	
		INSERT INTO [dbo].[table_central_logs]
           (
           [clinte_prod_acao_realizada]
           ,[id_usuario_desativado]
           ,[user_desat_flg_inclui]
           ,[user_desat_flg_exclui]
           ,[user_desat_flg_altera]
           ,[user_desat_flg_consulta]
           ,[user_desat_flg_aprova]
           ,[dat_desat]
		   ,[dat_inclusao]
		   )
		   SELECT 
		   NULL,
		   manutencao_p.usu_desativado,
		   acao_perfil.flg_inclui,
		   acao_perfil.flg_altera,
		   acao_perfil.flg_altera,
		   acao_perfil.flg_consulta,
		   acao_perfil.flg_aprova,
		   manutencao_p.dat_desativacao,
		   GETDATE()
		    FROM dbo.monutencao_log as manutencao_p
		   INNER JOIN dbo.usuario as usu1 on manutencao_p.usu_do_perfil_alterado = usu1.cod_usr
		   INNER JOIN dbo.perfil as perf on manutencao_p.usu_do_perfil_alterado = perf.cod_perf
		   INNER JOIN dbo.acao_perfil as acao_perfil on perf.cod_perf = acao_perfil.cod_perf
		   where usu1.dta_inat <> NULL and manutencao_p.processado = 0 
		   and  manutencao_p.dat_desativacao <> NULL

		   UPDATE dbo.monutencao_log set processado = 1 where processado = 0 
		   and  dat_desativacao <> NULL

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SET @NrErro = @@ERROR
		SET @DscErro = 'Erro ao gerar as provisões : ' + ERROR_MESSAGE()
		
		ROLLBACK TRANSACTION
		RETURN
	END CATCH
END
