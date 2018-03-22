set lines 200
set pages 9999
col PROFILE for a30
col RESOURCE_NAME for a30

var prof_name varchar2(30);

exec :prof_name := upper('&1');

select *
from dba_profiles
where PROFILE like :prof_name
;

/*
SQL> desc dba_profiles
 Name           Null?    Type
 -------------- -------- -------------
 PROFILE        NOT NULL VARCHAR2(30)
 RESOURCE_NAME  NOT NULL VARCHAR2(32)
 RESOURCE_TYPE           VARCHAR2(8)
 LIMIT                   VARCHAR2(40)

SQL>
*/