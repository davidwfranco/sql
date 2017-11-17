/* Proc created because of an issue found on a client where the 
   sequences of an database were with their curr number very behind 
   the actual value of the column thwy were used for */

SET SERVEROUTPUT ON SIZE UNLIMITED
SET FEEDBACK ON

DECLARE
    DIFF NUMBER;
    TAB_MAX_VAL NUMBER; 
    SQL_CMD VARCHAR2(150);
BEGIN
    /* Get the all the sequences on the database and link them with tables and column,
         but it only relate on cases where the sequence name coincides with table name or
         column name. */
    FOR I IN (SELECT DCC.OWNER, DCC.TABLE_NAME, DCC.COLUMN_NAME, 
                     DCC.CONSTRAINT_NAME, DS.SEQUENCE_NAME, DS.INCREMENT_BY, DS.LAST_NUMBER
                FROM ALL_CONS_COLUMNS DCC, ALL_SEQUENCES DS
               WHERE DCC.OWNER = DS.SEQUENCE_OWNER
                 AND DCC.TABLE_NAME = SUBSTR(DS.SEQUENCE_NAME,4) /* Swap TABLE_NAME with COLUMN_NAME 
                                                                    here if needed and change the 
                                                                    substring if needed also */
                 AND DCC.OWNER = 'BRAXTS_CFG'
                 AND DCC.CONSTRAINT_NAME NOT IN (SELECT CONSTRAINT_NAME 
                                                   FROM ALL_CONS_COLUMNS 
                                                  WHERE POSITION = 2)
                 AND DCC.CONSTRAINT_NAME IN (SELECT CONSTRAINT_NAME 
                                               FROM ALL_CONSTRAINTS 
                                              WHERE CONSTRAINT_TYPE IN ('U','P'))
                 AND DCC.CONSTRAINT_NAME LIKE '%PK%')
    LOOP
        /* For each Sequence / Table / Column returned above, get the max val on the field, subtract 
            the last val on the sequence from it and set it into the DIFF variable */
        SQL_CMD := 'SELECT A.MAX, (A.MAX - ' || I.LAST_NUMBER || ') FROM (SELECT MAX(' ||  
            I.COLUMN_NAME || ') AS MAX FROM BRAXTS_CFG.' || I.TABLE_NAME || ') A';
        
        EXECUTE IMMEDIATE SQL_CMD INTO TAB_MAX_VAL, DIFF;

         
        IF DIFF > 0 THEN

            /* Generate a header for log purposes with table name, seq name and col name */
            DBMS_OUTPUT.PUT_LINE('PROMPT --=== TAB: ' || I.TABLE_NAME || ' / SEQ: ' || 
                I.SEQUENCE_NAME || ' / COL: ' || I.COLUMN_NAME || ' ===--');
            DBMS_OUTPUT.PUT_LINE('--');

            /* More log purposes info, seq last val, column max val and difference between then */
            DBMS_OUTPUT.PUT_LINE('PROMPT --=== SEQ_CURR_VALL = ' || I.LAST_NUMBER || 
                ' / TAB_MAX_VAL: ' || TAB_MAX_VAL || ' / DIFF: ' || DIFF || ' ===--');
            DBMS_OUTPUT.PUT_LINE('--');

            /* From here on it's the correction cmds, with a alter sequence to raise the increment by with the diff, a call to seq nextval to equalize the values and an alter sequence to return the increment by value to the original */
            DBMS_OUTPUT.PUT_LINE('ALTER SEQUENCE BRAXTS_CFG.' || I.SEQUENCE_NAME || 
                ' INCREMENT BY ' || DIFF || ';');
            DBMS_OUTPUT.PUT_LINE('--');

            DBMS_OUTPUT.PUT_LINE('SELECT BRAXTS_CFG.'|| I.SEQUENCE_NAME  || '.NEXTVAL FROM DUAL;');
            DBMS_OUTPUT.PUT_LINE('--');

            DBMS_OUTPUT.PUT_LINE('ALTER SEQUENCE BRAXTS_CFG.' || I.SEQUENCE_NAME || 
                ' INCREMENT BY ' || I.INCREMENT_BY || ';');
            DBMS_OUTPUT.PUT_LINE('-- ');
        END IF;
    END LOOP;
END;
/
