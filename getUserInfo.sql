SET LINES 160
SET PAGES 9999
COL USERNAME FOR A17
COL ACCOUNT_STATUS FOR A18
COL HOST_NAME FOR A35
COL PROFILE FOR A15

SELECT INSTANCE_NAME AS INS_NAME,
       HOST_NAME, 
       USERNAME, 
       DEFAULT_TABLESPACE AS DEFAULT_TBS,
       ACCOUNT_STATUS, 
       TO_CHAR(CREATED, 'DD/MM/YYYY HH24:MI') AS CREATED, 
       PROFILE
  FROM DBA_USERS, V$INSTANCE
 WHERE USERNAME like ('&USERNAME')
 ORDER BY USERNAME
;
