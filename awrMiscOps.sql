-- Set the sqlplus basic format variables
SET LINES 165 PAGES 50000 LONG 10000 TIMI ON

-- AWR INFORMATION GATHERING

-- Get the dbid and instance_name from the awr history.
-- Usefull to work with multiple awr imported on a database, wich often occurs on performance analysis
-- The DBID can be used on all the other queries if needed
COL HOST_NAME FOR A35

SELECT DISTINCT DHI.DBID,
    DHI.INSTANCE_NAME AS "INSTANCE",
    DHI.HOST_NAME,
    DHI.VERSION
FROM DBA_HIST_DATABASE_INSTANCE DHI
;

-- Get the snap interval (in minutes) and retention period (in days)
SELECT DBID,
       (extract(day from snap_interval)*24*60 + 
                    extract(hour from snap_interval)*60 + 
                    extract(minute from snap_interval)) AS "Interval (Min)",
       extract(day from retention) AS "Retention (Dias)"
FROM dba_hist_wr_control;

-- Get the first an last snap ids and dates
COL FIRST_SNAP FOR A30
COL LAST_SNAP FOR A30

SELECT DBID, 
       INSTANCE_NUMBER, 
       MIN(SNAP_ID)||' - '||to_char(MIN(BEGIN_INTERVAL_TIME), 'DD/MM/YYYY HH24:MI') AS FIRST_SNAP, 
       MAX(SNAP_ID)||' - '||to_char(MAX(BEGIN_INTERVAL_TIME), 'DD/MM/YYYY HH24:MI') AS LAST_SNAP 
  FROM DBA_HIST_SNAPSHOT 
 GROUP BY DBID, INSTANCE_NUMBER;

-- AWR MODIFICATIONS

-- Take a snapshot
EXEC DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;

-- Change the snap interval
EXEC DBMS_WORKLOAD_REPOSITORY.MODIFY_SNAPSHOT_SETTINGS( INTERVAL=>'<INTERVAL_IN_MINUTES>');

-- Drop a series of spanhots
EXEC DBMS_WORKLOAD_REPOSITORY.DROP_SNAPSHOT_RANGE( '<BEGIN_SNAP_ID>' , '<END_SNAP_ID>');
