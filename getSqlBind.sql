/* Script created to get the binds used in the executions of a sql command in a dataframe */

COL NAME FOR A10
COL POS FOR '999'
COL TYPE FOR A13
COL VALUE_STRING FOR A20

var sqlid varchar2(20);
var begin_date varchar2(14);
var end_date varchar2(14);

exec :sqlid := '&1'
exec :begin_date := '&2'
exec :end_date := '&3'

SELECT dhs.SNAP_ID, 
       dhs.SQL_ID,
	   dhs.NAME,
	   dhs.POSITION POS,
	   dhs.DATATYPE_STRING TYPE,
	   dhs.VALUE_STRING
  FROM DBA_HIST_SQLBIND dhs, dba_hist_snapshot snap
 WHERE dhs.SNAP_ID = snap.SNAP_ID
   AND dhs.SQL_ID = :sqlid
   AND dhs.WAS_CAPTURED = 'YES'
   AND snap.begin_interval_time between to_date(:begin_date, 'yyyymmddhh24mi') and to_date(:end_date, 'yyyymmddhh24mi')
 ORDER BY dhs.SNAP_ID, dhs.POSITION, NAME
 ;