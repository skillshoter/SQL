USE [Banco]

IF NOT EXISTS
(
    SELECT
        1
    FROM
        INFORMATION_SCHEMA.COLUMNS
    WHERE
		UPPER(TABLE_NAME) = UPPER('tabela_de_senha')
        AND UPPER(COLUMN_NAME) = UPPER('qtd_alg')
)
BEGIN
	update tabela_de_senha set qtd_alg = 10 where Paramentro = 1 
END
