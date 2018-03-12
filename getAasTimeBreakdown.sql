-- Get the average active sessions for the provided period of time and presents it in csv format 

SET PAGES 50000
SET VERIFY OFF
SET LINES 180

alter session set nls_numeric_characters=',.';

accept p_btime       char   prompt 'Inicio (YYYYMMDDHH24MI): '
accept p_etime       char   prompt '   Fim (YYYYMMDDHH24MI): '
accept spool         char   prompt '       Arquivo de Saída: '

SPOOL &SPOOL

SELECT 'WAIT_DATE;INSTANCE_NUMBER;STAT_NAME;NUM_CPUS;MIN_WAIT;AVG_WAIT;P90_WAIT;P95_WAIT;P99_WAIT;MAX_WAIT' TITLE FROM DUAL
UNION ALL 
SELECT * 
  FROM ( SELECT TO_CHAR(TRUNC(SNAP_TIME,'MI') ,'YYYY/MM/DD HH24:MI:SS') ||';'|| --WAIT_DATE,
                INSTANCE_NUMBER ||';'|| --,
                STAT_NAME ||';'|| --,
                MAX(CPU_COUNT) ||';'|| --NUM_CPUS,
                ROUND(MIN(AAS),2) ||';'|| --MIN_WAIT,
                ROUND(AVG(AAS),2) ||';'|| --AVG_WAIT,
                ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY AAS),2) ||';'|| --P90_WAIT,
                ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY AAS),2) ||';'|| --P95_WAIT,
                ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY AAS),2) ||';'|| --P99_WAIT,
                ROUND(MAX(AAS),2) --MAX_WAIT
          FROM (SELECT BEGIN_INTERVAL_TIME SNAP_TIME,
                       STAT_NAME,
                       INSTANCE_NUMBER,
                       CPU_COUNT,
                       VALUE/SEC AAS
                  FROM (SELECT S.SNAP_ID,
                               S.BEGIN_INTERVAL_TIME,
                               S.INSTANCE_NUMBER,
                               G.STAT_NAME,
                               OS.VALUE AS CPU_COUNT,
                               (EXTRACT( DAY FROM (END_INTERVAL_TIME-BEGIN_INTERVAL_TIME) )*24*60*60 + 
                                 EXTRACT( HOUR FROM (END_INTERVAL_TIME-BEGIN_INTERVAL_TIME) )*60*60 + 
                                 EXTRACT( MINUTE FROM (END_INTERVAL_TIME-BEGIN_INTERVAL_TIME) )*60 + 
                                 EXTRACT( SECOND FROM (END_INTERVAL_TIME-BEGIN_INTERVAL_TIME)) ) SEC,
                               NVL( DECODE( GREATEST( G.VALUE, NVL(LAG(G.VALUE) OVER (PARTITION BY S.DBID, S.INSTANCE_NUMBER, G.STAT_NAME ORDER BY S.SNAP_ID),0) ), G.VALUE, G.VALUE - 
                                 LAG(G.VALUE) OVER (PARTITION BY S.DBID, S.INSTANCE_NUMBER, G.STAT_NAME ORDER BY S.SNAP_ID ), G.VALUE ), 0 )/1000000 VALUE
                          FROM DBA_HIST_SNAPSHOT S,
                               DBA_HIST_SYS_TIME_MODEL G,
                               DBA_HIST_OSSTAT OS 
                         WHERE S.SNAP_ID = G.SNAP_ID
                           AND S.BEGIN_INTERVAL_TIME BETWEEN TO_DATE('&p_btime','YYYYMMDDHH24MI')
                                                         AND TO_DATE('&p_etime','YYYYMMDDHH24MI')
                           AND S.INSTANCE_NUMBER  = G.INSTANCE_NUMBER
                           AND G.STAT_NAME        = 'DB time'
                           AND OS.INSTANCE_NUMBER = S.INSTANCE_NUMBER
                           AND OS.SNAP_ID         = S.SNAP_ID
                           AND OS.STAT_NAME       = 'NUM_CPUS'
                       )
               )
         GROUP BY TRUNC(SNAP_TIME,'MI'), STAT_NAME,INSTANCE_NUMBER
         ORDER BY 1
       )
/

SPOOL OFF

UNDEF p_btime p_etime spool 

SET FEEDBACK ON TRIMSPOOL OFF VERIFY ON