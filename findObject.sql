-- Script to find a object, its owner and type based on the object name or part of it

SET LINES 170
SET PAGES 9999
COL OWNER FOR A25
COL OBJECT_NAME FOR A30

var v_owner varchar2(30);

exec :v_owner := '&1';

SELECT DISTINCT OWNER, 
       OBJECT_NAME, 
       OBJECT_TYPE,
       TO_CHAR(CREATED, 'DD/MM/YYYY HH24:MI'),
       STATUS
  FROM DBA_OBJECTS 
 WHERE OBJECT_NAME like upper(:v_owner)
 ORDER BY 1, 2, 3
;
