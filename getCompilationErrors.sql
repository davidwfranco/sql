set lines 230 pages 5000 long 10000
col owner for a20
col name for a30
col "LIN/POS" for a8
col text for a168

select OWNER, 
    NAME, 
    LINE || '/' || POSITION as "LIN/POS",
    TEXT
from dba_errors
where owner = 'REPORTWEB'
order by owner, name, SEQUENCE
;


/*
SQL> desc dba_errors
 Name                                      Null?    Type
 ----------------------------------------- -------- ----------------------------
 OWNER                                     NOT NULL VARCHAR2(30)
 NAME                                      NOT NULL VARCHAR2(30)
 TYPE                                               VARCHAR2(12)
 SEQUENCE                                  NOT NULL NUMBER
 LINE                                      NOT NULL NUMBER
 POSITION                                  NOT NULL NUMBER
 TEXT                                      NOT NULL VARCHAR2(4000)
 ATTRIBUTE                                          VARCHAR2(9)
 MESSAGE_NUMBER                                     NUMBER
*/