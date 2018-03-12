set lines 200
set pages 50000
set long 1000000

var tbs_name varchar2(30);

exec :tbs_name := upper('&1');

select dt.TABLESPACE_NAME,
        ddf.FILE_NAME,
        ddf.BYTES/1024/1024 as U_SPACE_MB,
        ddf.MAXBYTES/1024/1024 as A_SPACE_MB,
        ddf.AUTOEXTENSIBLE
from dba_tablespaces dt, dba_data_files ddf
where dt.TABLESPACE_NAME = ddf.FILE_NAME
and dt.TABLESPACE_NAME like :tbs_name
;

/* Selected view information
desc dba_tablespaces
 Name                         Type
 ---------------------------- ---------------
 TABLESPACE_NAME              VARCHAR2(30)
 BLOCK_SIZE                   NUMBER
 INITIAL_EXTENT               NUMBER
 NEXT_EXTENT                  NUMBER
 MIN_EXTENTS                  NUMBER
 MAX_EXTENTS                  NUMBER
 MAX_SIZE                     NUMBER
 PCT_INCREASE                 NUMBER
 MIN_EXTLEN                   NUMBER
 STATUS                       VARCHAR2(9)
 CONTENTS                     VARCHAR2(9)
 LOGGING                      VARCHAR2(9)
 FORCE_LOGGING                VARCHAR2(3)
 EXTENT_MANAGEMENT            VARCHAR2(10)
 ALLOCATION_TYPE              VARCHAR2(9)
 PLUGGED_IN                   VARCHAR2(3)
 SEGMENT_SPACE_MANAGEMENT     VARCHAR2(6)
 DEF_TAB_COMPRESSION          VARCHAR2(8)
 RETENTION                    VARCHAR2(11)
 BIGFILE                      VARCHAR2(3)
 PREDICATE_EVALUATION         VARCHAR2(7)
 ENCRYPTED                    VARCHAR2(3)
 COMPRESS_FOR                 VARCHAR2(12)

 dba_data_files

 Name             Type
 ---------------- --------------
 FILE_NAME        VARCHAR2(513)
 FILE_ID          NUMBER
 TABLESPACE_NAME  VARCHAR2(30)
 BYTES            NUMBER
 BLOCKS           NUMBER
 STATUS           VARCHAR2(9)
 RELATIVE_FNO     NUMBER
 AUTOEXTENSIBLE   VARCHAR2(3)
 MAXBYTES         NUMBER
 MAXBLOCKS        NUMBER
 INCREMENT_BY     NUMBER
 USER_BYTES       NUMBER
 USER_BLOCKS      NUMBER
 ONLINE_STATUS    VARCHAR2(7)
*/

