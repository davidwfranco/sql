set serveroutput on size unlimited
set feedback on

DECLARE
    TYPE NamesList IS TABLE OF VARCHAR2(30);  -- nested table type
    usernames NamesList := NamesList(
      'USER_847448','USER_928866','USER_993233','USER_886618','USER_A34104'
    );
    tempTbsName VARCHAR2(50);
    v_count NUMBER;
    vPasswd VARCHAR2(20);
BEGIN
    SELECT DISTINCT tablespace_name 
        INTO tempTbsName 
        FROM dba_temp_files WHERE ROWNUM = 1;
    FOR i IN usernames.FIRST .. usernames.LAST 
    LOOP
        v_count := 0;
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

        SELECT COUNT(*)
        INTO v_count
        FROM DBA_USERS
        WHERE USERNAME = usernames(i);

        IF v_count > 0 THEN
            EXECUTE IMMEDIATE 'DROP USER "' || usernames(i) || '" CASCADE';
        END IF;

        DBMS_OUTPUT.PUT_LINE('--====>> CREATE USER - ' || usernames(i));

        EXECUTE IMMEDIATE 'CREATE USER "' || usernames(i) || '" IDENTIFIED BY ' || vPasswd || ' ' ||
            'DEFAULT TABLESPACE USERS ' ||
            'TEMPORARY TABLESPACE ' || tempTbsName;
        EXECUTE IMMEDIATE 'GRANT SELECT_CATALOG_ROLE TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT SELECT ANY DICTIONARY TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT RESOURCE TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'ALTER USER "' || usernames(i) || '" DEFAULT ROLE ALL';

        DBMS_OUTPUT.PUT_LINE('User --> ' || usernames(i) || ' / Pass --> ' || vPasswd);
    END LOOP;
END;
/

--exit;