set serveroutput on size unlimited
set feedback on

DECLARE
  
  TYPE NamesList IS TABLE OF VARCHAR2(30);  -- nested table type
  usernames NamesList := NamesList(
    'USERR_NAME_TO_CREATE'
  );

  tempTbsName VARCHAR2(50);

  v_count NUMBER;

BEGIN

    select distinct tablespace_name 
      INTO tempTbsName 
      from dba_temp_files where rownum = 1;

    FOR i IN usernames.FIRST .. usernames.LAST 
    LOOP

        v_count := 0;

        SELECT COUNT(*)
          INTO v_count
          FROM ALL_USERS
         WHERE USERNAME = usernames(i);

        IF v_count > 0 THEN
          EXECUTE IMMEDIATE 'DROP USER "' || usernames(i) || '" CASCADE';
        END IF;

        DBMS_OUTPUT.PUT_LINE('--====>> CREATE USER - ' || usernames(i));
        EXECUTE IMMEDIATE 'CREATE USER "' || usernames(i) || '" IDENTIFIED BY AAA#bbb#CCC#123 ' ||
              'DEFAULT TABLESPACE USERS ' ||
              'TEMPORARY TABLESPACE ' || tempTbsName;
        EXECUTE IMMEDIATE 'GRANT SELECT_CATALOG_ROLE TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT SELECT ANY DICTIONARY TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'GRANT RESOURCE TO "' || usernames(i) || '"';
        EXECUTE IMMEDIATE 'ALTER USER "' || usernames(i) || '" DEFAULT ROLE ALL';

        FOR roles IN (SELECT ROLE AS NAME 
                        FROM DBA_ROLES 
                       WHERE ROLE LIKE '%READ')
        LOOP
            DBMS_OUTPUT.PUT_LINE('--======>> GRANT ' || roles.NAME || ' TO ' || usernames(i));
            EXECUTE IMMEDIATE 'GRANT ' || roles.NAME || ' TO ' || usernames(i);
        END LOOP;
    END LOOP;
END;
/

exit;