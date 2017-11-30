set lines 180 pages 50000 feedback on autoprint on serveroutput on size unlimited

DECLARE
    TYPE NamesList IS TABLE OF VARCHAR2(35);
    usernames NamesList := NamesList('ADMA88719');
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
          FROM DBA_USERS
         WHERE USERNAME = usernames(i);

        IF v_count > 0 THEN
            EXECUTE IMMEDIATE 'DROP USER ' || usernames(i) || ' CASCADE';
        END IF;

        DBMS_OUTPUT.PUT_LINE('--====>> CREATE USER - ' || usernames(i));
        EXECUTE IMMEDIATE 'CREATE USER ' || usernames(i) || ' IDENTIFIED BY C#arm4nder#001 ' ||
              'DEFAULT TABLESPACE USERS ' ||
              'TEMPORARY TABLESPACE ' || tempTbsName;
        EXECUTE IMMEDIATE 'GRANT DBA TO ' || usernames(i);
        EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO ' || usernames(i);
        EXECUTE IMMEDIATE 'ALTER USER ' || usernames(i) || ' PROFILE ADMINISTRADOR';
    END LOOP;
END;
/

exit;
