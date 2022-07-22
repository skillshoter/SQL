USE [BANCO]
		
		SELECT FROM dbo.manutencao_log as log_m
		   INNER JOIN dbo.usuario as usu1 on log_m.usu_perf_alt = usu1.cod_usr
		   INNER JOIN dbo.perfil as perf on log_m.usu_perf_alt = perf.cod_perf
		   INNER JOIN dbo.perfil_acao as perfil_acao on perf.cod_perf = perfil_acao.cod_perf
		   where usu1.dta_inat <> NULL and log_m.processado = 0 
		   and  log_m.dta_desativacao <> NULL