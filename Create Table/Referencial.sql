USE [banco]
GO

IF OBJECT_ID ('[DBO].[table_name]') IS NULL
    BEGIN
		
        CREATE TABLE table_name
            (
                id_log int NOT NULL identity(1,1),
				nom_sist_ori VARCHAR(50),
				dat_ini_sessao DATETIME,				
				dat_fim_sessao DATETIME,
				id_user_sessao INT,
				ativo BIT
				);
    END;


