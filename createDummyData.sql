set lines 165
set pages 50000
set long 100000
set serveroutput on size unlimited

/* Create tables */

CREATE TABLE DUMMY_DATA_01 
    (ID NUMBER, 
    DUMMY_TEXT VARCHAR(20), 
    DUMMY_DATE DATE,
    CONSTRAINT DUMMY_PK PRIMARY KEY (ID));

create index dummy_idx_01 on dummy_data_01 (id, dummy_date);

create sequence dummy_seq increment by 1 start with 1;

/* generate data */
begin
    for i in 1..5000 loop
        insert into dummy_data_01 (id, dummy_text, dummy_date)
            values (dummy_seq.nextval, DBMS_RANDOM.STRING('a', 20), sysdate + DBMS_RANDOM.value(-1000, 0));
    end loop;
end;
/

-- CREATE TABLE test_table AS
-- SELECT LEVEL id, SYSDATE+DBMS_RANDOM.VALUE(-1000, 1000) date_value, DBMS_RANDOM.string('A', 20) text_value
-- FROM dual
-- CONNECT BY LEVEL <= 100000