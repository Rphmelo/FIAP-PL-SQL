-- EXERCICIOS

-- Exibe o texto armazenado na variavel v_texto
DECLARE
  v_texto VARCHAR2(100) := 'Eu, ' || user || ', serei um bom desenvolvedor PL-SQL!'; 
BEGIN
  DBMS_OUTPUT.put_line(v_texto);
END;

-- Exibe a quantidade de dias vividos por uma pessoa com base em sua data de nascimento
DECLARE 
  v_data_nascimento DATE := '27/03/2016';
  v_data_hoje DATE := SYSDATE;
  v_total_dias NUMERIC;
  v_texto VARCHAR2(100);
BEGIN
  v_total_dias := v_data_hoje - v_data_nascimento;
  v_texto := 'Eu tenho '||v_total_dias||' dias de vida';
  DBMS_OUTPUT.PUT_LINE(v_texto);
END;

-- Exibe a quantidade de meses vividos por uma pessoa com base em sua data de nascimento
DECLARE
  v_data_nascimento DATE := '05/08/1997';
  v_data_hoje DATE := SYSDATE;
  v_total_meses NUMERIC;
  v_texto VARCHAR2(100);
BEGIN
  v_total_meses := MONTHS_BETWEEN(v_data_hoje, v_data_nascimento);
  v_texto := 'Eu tenho ' || v_total_meses || ' meses de vida.';
  DBMS_OUTPUT.PUT_LINE(v_texto);
END;

-- Exibe a quantidade de anos vividos por uma pessoa com base em sua data de nascimento
DECLARE
  v_data_nascimento DATE := '29/05/2015';
  v_data_hoje DATE := SYSDATE;
  v_total_anos NUMERIC;
  v_texto VARCHAR2(100);
BEGIN 
  v_total_anos := (MONTHS_BETWEEN(v_data_hoje, v_data_nascimento) / 12);
  v_texto := 'Eu tenho ' ||v_total_anos || ' anos de idade.';
  DBMS_OUTPUT.PUT_LINE(v_texto);
END;

-- Exibe o nome do dia da semana de uma determinada data
DECLARE
  v_texto VARCHAR2(100);
  v_data_hoje DATE := SYSDATE;
  v_dia_semana VARCHAR2(100);
BEGIN
  v_dia_semana := TO_CHAR(v_data_hoje, 'day');
  v_texto := 'Hoje, '||v_data_hoje|| ', 
            estamos no seguinte dia da semana: '||v_dia_semana;
  DBMS_OUTPUT.PUT_LINE(v_texto);
END;

-- Multiplica dois números passados como parâmetro
DECLARE
  v_valor1 NUMERIC := &NUMERO1;
  v_valor2 NUMERIC := &NUMERO2;
  v_texto VARCHAR2(100);
  v_calculo NUMERIC;
BEGIN
  v_calculo := v_valor1 * v_valor2;
  v_texto := 'A multiplicação de '||v_valor1||' e '
            ||v_valor2|| ' é igual a '||v_calculo;
  DBMS_OUTPUT.PUT_LINE(v_texto);
END;

/* EXIBE AS DATAS DE 365 DIAS 
QUE VIRÃO DEPOIS DE UMA DATA PASSADA COMO PARÂMETRO */

DECLARE
  v_data_atual DATE;
  v_data DATE;
BEGIN
  v_data_atual := '&Data';
  FOR X IN 1..365 LOOP
    SYS.DBMS_OUTPUT.PUT_LINE(TO_DATE(v_data_atual, 'dd/mm/yyyy') + X);
  END LOOP;
END;

-- Exercício que popula uma tabela com dados de outra tabela
CREATE TABLE LOC_LOG
(DATA DATE, 
LOG VARCHAR2 (4000)
);

ALTER TABLE LOC_LOG
ADD CONSTRAINT PK_LOC_LOG
PRIMARY KEY (DATA);

set serveroutput on
declare
  v_cd_banco  loc_banco.cd_banco%type := &Codigo_Banco;
  v_nm_banco  loc_banco.nm_banco%type;
  v_banco_inexistente exception;
  cursor c_banco is
    select nm_banco
      from loc_banco
     where cd_banco = v_cd_banco;
  --v_banco c_banco%rowtype;
begin
  open c_banco;
  loop
    --fetch c_banco into v_banco;
    fetch c_banco into v_nm_banco;
    exit when c_banco%notfound;
  end loop;
    if v_nm_banco is null then
      raise v_banco_inexistente;
    else
      insert into LOC_LOG (data, log) values (sysdate,'Consulta Banco=>'|| v_cd_banco);
      commit;
    end if; 
  dbms_output.put_line ('Banco=>' || v_nm_banco);
exception
  when v_banco_inexistente then
    raise_application_error(-20001,'O banco de código ' || v_cd_banco || ' não está cadastrado!');
  when others then
    raise_application_error(-20002,'Erro genérico ' || sqlerrm);
end;

-- Exibe a quantidade de caracteres de um varchar
DECLARE
   v_texto VARCHAR(50) := 'Raphael';
   v_length NUMERIC;
BEGIN
   v_length := LENGTH(v_texto);
   DBMS_OUTPUT.PUT_LINE(v_length);
END;

-- Transforma a primeira letra de um varchar passado como parametro em maiúscula
DECLARE
   v_texto VARCHAR(50) := 'raphael';
BEGIN
   DBMS_OUTPUT.PUT_LINE(INITCAP(v_texto));
END;

-- IMPRIMI TODOS OS FUNCIONÁRIOS DE UM DETERMINADO DEPARTAMENTO

DECLARE
  CURSOR C_DEPTO IS SELECT * FROM LOC_DEPTO;
  CURSOR C_FUNC(P_CD_DEPTO LOC_DEPTO.CD_DEPTO%TYPE) IS SELECT NM_FUNC 
  FROM LOC_FUNCIONARIO WHERE CD_DEPTO = P_CD_DEPTO;
  V_DEPTO  C_DEPTO%ROWTYPE;
  V_FUNC  C_FUNC%ROWTYPE;
BEGIN

  OPEN C_DEPTO;
  LOOP
    FETCH C_DEPTO INTO V_DEPTO;
    EXIT WHEN C_DEPTO%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(V_DEPTO.NM_DEPTO);
    OPEN C_FUNC(V_DEPTO.CD_DEPTO);
    LOOP
      FETCH C_FUNC INTO V_FUNC;
      EXIT WHEN C_FUNC%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  '||V_FUNC.NM_FUNC);
     END LOOP; 
     CLOSE C_FUNC;
  END LOOP;
  CLOSE C_DEPTO;
END;

-- Atualiza o número de estrelas de um cliente com base na quantidade de pedidos que ele fez
DECLARE

CURSOR C_PEDIDO_LOCACAO IS SELECT CD_CLIENTE, COUNT(NR_PEDIDO) AS NUM_PEDIDO  
FROM LOC_PEDIDO_LOCACAO GROUP BY CD_CLIENTE;

V_PEDIDO_LOCACAO C_PEDIDO_LOCACAO%ROWTYPE;

V_NR_ESTRELAS LOC_CLIENTE.NR_ESTRELAS%TYPE;

V_NUM_PEDIDO NUMBER;

BEGIN 
  OPEN C_PEDIDO_LOCACAO;
  LOOP
    FETCH C_PEDIDO_LOCACAO INTO V_PEDIDO_LOCACAO;
    EXIT WHEN C_PEDIDO_LOCACAO%NOTFOUND;
    V_NUM_PEDIDO := V_PEDIDO_LOCACAO.NUM_PEDIDO;
    IF (V_NUM_PEDIDO >= 0 AND V_NUM_PEDIDO <= 5) THEN
      V_NR_ESTRELAS := 1;
    ELSIF(V_NUM_PEDIDO >= 6 AND V_NUM_PEDIDO <= 20) THEN
      V_NR_ESTRELAS := 2;
    ELSIF(V_NUM_PEDIDO >= 21 AND V_NUM_PEDIDO <= 100) THEN
      V_NR_ESTRELAS := 3;
    ELSIF(V_NUM_PEDIDO >= 101 AND V_NUM_PEDIDO <= 150) THEN
      V_NR_ESTRELAS := 4;
    ELSIF(V_NUM_PEDIDO > 150) THEN
      V_NR_ESTRELAS := 5;
    END IF;
    UPDATE LOC_CLIENTE SET NR_ESTRELAS = V_NR_ESTRELAS WHERE CD_CLIENTE = V_PEDIDO_LOCACAO.CD_CLIENTE;
  END LOOP;
  CLOSE C_PEDIDO_LOCACAO;
  COMMIT;
END;

/*
Realiza a leitura dos registros da tabela ORIGEM_DADOS e insere na estrutura listada abaixo:

CREATE TABLE COPIA_DADOS (cp1 number primary key, cp2 varchar2(4000), cp3 varchar2(4000));

Equivalência de campos:
 ORIGEM_DADOS => COPIA_DADOS
 CAMPO3       =  CP1
 CAMPO1	      =  CP2
 CAMPO2       =  CP3
*/

CREATE TABLE COPIA_DADOS (cp1 number primary key, cp2 varchar2(4000), cp3 varchar2(4000));

declare
  cursor c_origem is
    select campo3, campo1, campo2
      from origem_dados;
   v_origem c_origem%rowtype;
begin
  open c_origem;
  loop
    fetch c_origem into v_origem;
    exit when c_origem%notfound;
    begin
      insert into copia_dados (cp1, cp2, cp3) values
        (v_origem.campo3, v_origem.campo1, v_origem.campo2);
    exception
      when dup_val_on_index then
        update copia_dados 
          set cp2 = v_origem.campo1, cp3 = v_origem.campo2
        where cp1 = v_origem.campo3;
      when others then
        raise_application_error(-20001,'Erro ao processar o CURSOR ' || sqlerrm);
    end;
  end loop;
  close c_origem;
  commit;
exception
  when others then
    raise_application_error(-20002,'Erro Genérico ' || sqlerrm);
end;