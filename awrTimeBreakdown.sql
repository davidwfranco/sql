set serveroutput on size unlimited
set feedback off
set trimspool on
set pages 0
set verify off

alter session set nls_numeric_characters=',.';

accept p_btime       char   prompt 'Inicio (yyyymmddhh24mi): '
accept p_etime       char   prompt '   Fim (yyyymmddhh24mi): '
accept p_qtdd_events number prompt '  Quantidade de Eventos: '
accept p_inst_id     number prompt '            Instance ID: '
accept spool         char   prompt '       Arquivo de Saida: '

spool &spool
declare
    btime date := to_date('&p_btime','yyyymmddhh24mi');
    etime date := to_date('&p_etime','yyyymmddhh24mi');

    i integer := 0;
    last_startup date;
    last_id integer;
    last_datahora varchar2(20);

    cursor c_snap is
        select snap_id, startup_time, to_char(end_interval_time,'dd/mm/yyyy hh24:mi') datahora
          from sys.dba_hist_snapshot
         where end_interval_time between btime and etime
           and instance_number = &p_inst_id
         order by end_interval_time;

    cursor c_data (v_bid in integer, v_eid in integer) is
        select event,
               time time_s
          from ( select e.event_name event,
                        (e.time_waited_micro - nvl(b.time_waited_micro,0))/1000000 time
                   from sys.dba_hist_system_event b,
                        sys.dba_hist_system_event e
                  where b.snap_id(+)          = v_bid
                    and e.snap_id             = v_eid
                    and b.instance_number = &p_inst_id
                    and e.instance_number = &p_inst_id
                    and b.event_id(+)         = e.event_id
                    and e.total_waits         > nvl(b.total_waits,0)
                    and e.wait_class not in ('Idle')
                  UNION ALL
                 select 'CPU' event, (e.value-b.value)/1000000 time
                   from sys.dba_hist_sys_time_model b, sys.dba_hist_sys_time_model e
                  where e.snap_id         = v_eid
                    and b.snap_id         = v_bid
                    and b.instance_number = &p_inst_id
                    and e.instance_number = &p_inst_id
                    and e.stat_name       = 'DB CPU'
                    and b.stat_name       = 'DB CPU'
                  order by time desc
               )
         where rownum <= &p_qtdd_events
           and time > 0;

begin
   dbms_output.put_line('SnapID;DataHora;Evento;Tempo(s)');
   for r_snap in c_snap loop
       i := i+1;
       if (i > 1) and (r_snap.startup_time = last_startup) then
         for r_data in c_data (last_id, r_snap.snap_id) loop
          dbms_output.put_line(last_id||';'||last_datahora||';'||r_data.event||';'||round(r_data.time_s));
         end loop;   -- for r_data in c_data loop
       end if;
       last_startup := r_snap.startup_time;
       last_id      := r_snap.snap_id;
       last_datahora:= r_snap.datahora;
   end loop;      -- for r_snap in c_snaps loop
end;
/

spool off
undef p_btime p_etime p_inst_id p_qtdd_events spool

set feedback on trimspool off pages 9999 verify on
