--1.2 Crie uma tabela apropriada para o armazenamento dos itens. Não se preocupe com a
--normalização. Uma tabela basta.
--Criação tabela 
CREATE TABLE student_prediction (
idade INT,
genero INT,
salario INT,
prep_exame INT,
notas INT,
grade INT
);

--Copiando dados na tabela
-- Modelo COPY SQL
--COPY student_prediction (idade, genero, salario, prep_exame, notas, grade)
--FROM '\base\13_projeto_base_de_dados_student_prediction.csv' DELIMITER ',' CSV HEADER;
-- Porém utilizamos o import pelo PGADMIN

-- Visualizando tabela
SELECT * FROM student_prediction;


--1.4 Escreva os seguintes stored procedures (incluindo um bloco anônimo de teste para cada
--um):

-- Criando procedure de exibir números de estudantes maiores de idade
DROP PROCEDURE IF EXISTS sp_exibe_maior_idade;

--1.4.1 Exibe o número de estudantes maiores de idade.
-- Criação da stored procedure
CREATE OR REPLACE PROCEDURE sp_exibe_maior_idade(OUT resultado INT)
LANGUAGE plpgsql
AS $$
DECLARE
	idade_registro INT;
BEGIN
	-- Inicializa o resultado
	resultado := 0;
	
	-- No modelo do kaggle da seguinte forma: 
	-- Student Age (1: 18-21, 2: 22-25, 3: above 26)
	-- Porém como esse modo de classificação do dataset não abrange todas as possíbilidades,
	-- resolvemos colocar no modo padrão de idade, sem a classificação, dessa forma irá abranger todas
	-- as possíbilidades.
	
	-- Loop para percorrer os registros da tabela
	FOR idade_registro IN SELECT idade FROM student_prediction LOOP
		IF idade_registro >= 1 THEN
			resultado := resultado + 1;
		END IF;
	END LOOP;
END;
$$;

-- Bloco anônimo de teste
DO $$
DECLARE
	numero_estudantes_maiores INT;
BEGIN
	CALL sp_exibe_maior_idade(numero_estudantes_maiores);
	RAISE NOTICE 'O número de estudantes maiores de idade é %', numero_estudantes_maiores;
END $$;


--Exercicio percentual  .
--1.4.2 Exibe o percentual de estudantes de cada sexo.

-- Drop procedure se existir
DROP PROCEDURE IF EXISTS sp_exibe_porcentual_sexo;

-- Criação da stored procedure
CREATE OR REPLACE PROCEDURE sp_exibe_porcentual_sexo(
    OUT resultado_m NUMERIC (5,2),
    OUT resultado_f NUMERIC (5,2),
    OUT quant_total INT)
LANGUAGE plpgsql
AS $$
DECLARE
    quant_m INT;
    quant_f INT;
BEGIN
    -- Inicializa o resultado
    resultado_m := 0;
    resultado_f := 0;
    quant_total := 0;

    -- Conta a quantidade de valores masculinos
    SELECT COUNT(*) INTO quant_m FROM student_prediction WHERE genero = 2;

    -- Conta a quantidade de valores femininos
    SELECT COUNT(*) INTO quant_f FROM student_prediction WHERE genero = 1;

    -- Soma as contagens para obter a quantidade total
    quant_total := quant_m + quant_f;

    -- Calcula os resultados percentuais
    IF quant_total > 0 THEN
        resultado_m := (quant_m * 100.0) / quant_total;
        resultado_f := (quant_f * 100.0) / quant_total;
    END IF;
END;
$$;

-- Bloco anônimo de teste
DO $$
DECLARE
    resultado_m NUMERIC (5,2);
    resultado_f NUMERIC (5,2);
    quant_total INT;
BEGIN
    CALL sp_exibe_porcentual_sexo(resultado_m, resultado_f, quant_total);
    RAISE NOTICE 'A porcentagem de homens é % %%. E a de mulheres é % %%. Além disso, a quantidade total de amostras H e M é de %', resultado_m, resultado_f, quant_total;
END $$;


--1.4.3 Recebe um sexo como parâmetro em modo IN e utiliza oito parâmetros em modo OUT
--para dizer qual o percentual de cada nota (variável grade) obtida por estudantes daquele
--sexo

CREATE OR REPLACE PROCEDURE sp_percentual_notas_por_sexo(
    IN sexo_param INT,
    OUT percentual_nota_1 NUMERIC (5,2),
    OUT percentual_nota_2 NUMERIC (5,2),
    OUT percentual_nota_3 NUMERIC (5,2),
    OUT percentual_nota_4 NUMERIC (5,2),
    OUT percentual_nota_5 NUMERIC (5,2),
    OUT percentual_nota_6 NUMERIC (5,2),
    OUT percentual_nota_7 NUMERIC (5,2),
    OUT percentual_nota_8 NUMERIC (5,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    total_registros INT;
BEGIN
    -- Inicializa os resultados
    percentual_nota_1 := 0;
    percentual_nota_2 := 0;
    percentual_nota_3 := 0;
    percentual_nota_4 := 0;
    percentual_nota_5 := 0;
    percentual_nota_6 := 0;
    percentual_nota_7 := 0;
    percentual_nota_8 := 0;

    -- Calcula o total de registros para o sexo específico
    SELECT COUNT(*) INTO total_registros FROM student_prediction WHERE genero = sexo_param;

    -- Verifica se o total de registros é maior que zero para evitar divisão por zero
    IF total_registros > 0 THEN
        -- Calcula os percentuais para cada nota
        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_1
        FROM student_prediction WHERE grade = 0 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_2
        FROM student_prediction WHERE grade = 1 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_3
        FROM student_prediction WHERE grade = 2 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_4
        FROM student_prediction WHERE grade = 3 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_5
        FROM student_prediction WHERE grade = 4 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_6
        FROM student_prediction WHERE grade = 5 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_7
        FROM student_prediction WHERE grade = 6 AND genero = sexo_param;

        SELECT
            (COUNT(*) * 100.0) / total_registros INTO percentual_nota_8
        FROM student_prediction WHERE grade = 7 AND genero = sexo_param;
    END IF;
END;
$$;


-- Bloco anônimo de teste
DO $$
DECLARE
    resultado_nota_1 NUMERIC (5,2);
    resultado_nota_2 NUMERIC (5,2);
    resultado_nota_3 NUMERIC (5,2);
    resultado_nota_4 NUMERIC (5,2);
    resultado_nota_5 NUMERIC (5,2);
    resultado_nota_6 NUMERIC (5,2);
    resultado_nota_7 NUMERIC (5,2);
    resultado_nota_8 NUMERIC (5,2);
    sexo_param INT;
BEGIN
    -- Defina o sexo para teste (1 para feminino, 2 para masculino, ajuste conforme necessário)
    sexo_param := 1;

    -- Chame a stored procedure
    CALL sp_percentual_notas_por_sexo(sexo_param, resultado_nota_1, resultado_nota_2, resultado_nota_3, resultado_nota_4, resultado_nota_5, resultado_nota_6, resultado_nota_7, resultado_nota_8);

    -- Exiba os resultados
    RAISE NOTICE 'Percentual da nota 1: %.%%', resultado_nota_1;
    RAISE NOTICE 'Percentual da nota 2: %.%%', resultado_nota_2;
    RAISE NOTICE 'Percentual da nota 3: %.%%', resultado_nota_3;
    RAISE NOTICE 'Percentual da nota 4: %.%%', resultado_nota_4;
    RAISE NOTICE 'Percentual da nota 5: %.%%', resultado_nota_5;
    RAISE NOTICE 'Percentual da nota 6: %.%%', resultado_nota_6;
    RAISE NOTICE 'Percentual da nota 7: %.%%', resultado_nota_7;
    RAISE NOTICE 'Percentual da nota 8: %.%%', resultado_nota_8;
END $$;

-- 1.5 Escreva as seguintes functions (incluindo um bloco anônimo de teste para cada uma):

--1.5.1 Responde (devolve boolean) se é verdade que todos os estudantes de renda acima de
--410 são aprovados (grade > 0).


CREATE OR REPLACE FUNCTION fn_renda_410() RETURNS BOOLEAN AS
$$
DECLARE
    resultado BOOLEAN;
    total_registros INT;
BEGIN
    -- Calcula o total de registros na tabela
    SELECT COUNT(*) INTO total_registros FROM student_prediction;

    -- Verifica se há algum registro na tabela
    IF total_registros > 0 THEN
        -- Verifica se todos os estudantes com renda acima de 410 são aprovados
        SELECT
            CASE WHEN COUNT(*) = COUNT(*) FILTER(WHERE grade > 0) THEN
                TRUE
            ELSE
                FALSE
            END
        INTO resultado
        FROM student_prediction
        WHERE salario > 410;
    ELSE
        resultado := FALSE; -- Trata o caso em que não há registros na tabela
    END IF;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

--Bloco anonimo de teste
DO $$
DECLARE
    resultado BOOLEAN;
BEGIN
    resultado := fn_renda_410();

    IF resultado THEN
        RAISE NOTICE 'Todos os estudantes com renda acima de 410 são aprovados.';
    ELSE
        RAISE NOTICE 'Existem estudantes com renda acima de 410 que não são aprovados.';
    END IF;
END $$;


--1.5.2 Responde (devolve boolean) se é verdade que, entre os estudantes que fazem
--anotações pelo menos algumas vezes durante as aulas, pelo menos 70% são aprovados
--(grade > 0).

CREATE OR REPLACE FUNCTION fn_anotacoes_aprovados() RETURNS BOOLEAN AS
$$
DECLARE
    resultado BOOLEAN;
    total_registros INT;
    aprovados INT;
BEGIN
    -- Calcula o total de registros na tabela
    SELECT COUNT(*) INTO total_registros FROM student_prediction;

    -- Verifica se há algum registro na tabela
    IF total_registros > 0 THEN
        -- Verifica se pelo menos 70% dos estudantes que fazem anotações são aprovados
        SELECT
            CASE WHEN COUNT(*) * 0.7 <= COUNT(*) FILTER(WHERE grade > 0) THEN
                TRUE
            ELSE
                FALSE
            END
        INTO resultado
        FROM student_prediction
        WHERE notas >1; -- Substitua faz_anotacoes pelo nome real da coluna que indica se o estudante faz anotações
    ELSE
        resultado := FALSE; -- Trata o caso em que não há registros na tabela
    END IF;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

-- Bloco anônimo de teste
DO $$
DECLARE
    resultado BOOLEAN;
BEGIN
    resultado := fn_anotacoes_aprovados();

    IF resultado THEN
        RAISE NOTICE 'Pelo menos 70%% dos estudantes que fazem anotações são aprovados.';
    ELSE
        RAISE NOTICE 'Menos de 70%% dos estudantes que fazem anotações são aprovados.';
    END IF;
END $$;


--Devolve o percentual de alunos que se preparam pelo menos um pouco para os
--“midterm exams” e que são aprovados (grade > 0).
CREATE OR REPLACE FUNCTION fn_preparacao_midterm_aprovados() RETURNS NUMERIC(5,2) AS
$$
DECLARE
    percentual NUMERIC(5,2);
    total_registros INT;
    aprovados INT;
BEGIN
    -- Calcula o total de registros na tabela
    SELECT COUNT(*) INTO total_registros FROM student_prediction;

    -- Verifica se há algum registro na tabela
    IF total_registros > 0 THEN
        -- Calcula o percentual de alunos que se preparam pelo menos um pouco para os "midterm exams" e que são aprovados
        SELECT
            (COUNT(*) FILTER(WHERE prep_exame IN (1, 2) AND grade > 0) * 100.0) / COUNT(*) INTO percentual
        FROM student_prediction;
    ELSE
        percentual := 0; -- Trata o caso em que não há registros na tabela
    END IF;

    RETURN percentual;
END;
$$ LANGUAGE plpgsql;

--Bloco anônimo de teste
DO $$
DECLARE
    percentual_aprovados_midterm NUMERIC(5,2);
BEGIN
    percentual_aprovados_midterm := fn_preparacao_midterm_aprovados();

    RAISE NOTICE 'O percentual de alunos que se preparam pelo menos um pouco para os "midterm exams" e são aprovados é % %%', percentual_aprovados_midterm;
END $$;