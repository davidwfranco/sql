set lines 190 pages 50000 long 10000
set serveroutput on size unlimited

DECLARE
    vPasswd varchar2(50);
BEGIN   
    vPasswd := DBMS_RANDOM.STRING('a', 1);
    FOR i IN 1 .. 11
    LOOP
        CASE ROUND(DBMS_RANDOM.VALUE(1,5))
            WHEN 1 THEN
                vPasswd := vPasswd || ROUND(DBMS_RANDOM.VALUE(0, 10));
            WHEN 2 THEN
                vPasswd := vPasswd || '#';
            ELSE
                vPasswd := vPasswd || DBMS_RANDOM.STRING('a', 1);
        END CASE;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(vPasswd);
END;
/