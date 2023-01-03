use tkgs_cap


select * from cap_propostas p 
 cross apply (
	select * from cap_propostas_titulares e 
	where p.cod_ctr = e.cod_Ctr
 ) a

 select * from cap_propostas p 
	outer apply (
	 select * from cap_propostas_titulares e 
	 where p.cod_ctr =e.cod_ctr
	) n