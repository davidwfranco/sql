set lines 165 
set serveroutput on size unlimited
set feedback off
set trimspool on
set pages 0
set verify off
col EVENT_NAME for a70

alter session set nls_numeric_characters=',.';

accept begin_date char prompt 'Inicio (yyyymmddhh24mi): '
accept end_date   char prompt '   Fim (yyyymmddhh24mi): '
accept spool      char prompt '       Arquivo de Saida: '

spool &spool

SELECT EVENT_NAME||';'||
       DELTA_SECS||';'||
       trunc(100 * ratio_to_report(DELTA_SECS) over(partition by TOTAL), 2) as "Ev_Name;Tempo(s);Ratio"
  FROM (select 'Total' AS "TOTAL",
               event_name,
               TRUNC(sum(DELTA_EVENT) / 1000000, 2) "DELTA_SECS"
          FROM (select ev.snap_id,
                       EV.event_name,
                       ev.time_waited_micro -
                       (lag(ev.time_waited_micro)
                        over(partition by null order by ev.snap_id)) as "DELTA_EVENT"
                  from dba_hist_system_event ev, dba_hist_snapshot sn
                 where ev.snap_id = sn.snap_id
                   and ev.wait_class <> 'Idle'
		           and sn.INSTANCE_NUMBER = &instance_id
                   /*and to_CHAR(sn.end_interval_time, 'DD/MM/YYYY HH24:MI') between
                       '08/03/2012 00:00' AND '09/03/2012 23:00:00'*/
				   and sn.BEGIN_INTERVAL_TIME BETWEEN to_date(&begin_date, 'yyyymmddhh24mi') AND to_date(&end_date, 'yyyymmddhh24mi')
				)
         GROUP BY EVENT_NAME
         having TRUNC(sum(DELTA_EVENT) / 1000000, 2) > 0)
 order by 3 desc;

spool off
undef begin_date end_date spool

set feedback on trimspool off pages 9999 verify on
