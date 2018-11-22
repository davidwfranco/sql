accept snap_inicial number prompt 'Snapshot ID inicial: '
accept snap_final   number prompt '  Snapshot ID final: '
accept topn         number prompt ' Top-N (default 25): '
accept opt          number prompt 'Ordenar por (1-BufGets, 2-DskReads, 3-CPU_TIME, 4-Elapsed_time,5-Parses, 6-Execs): '

column pct format 990.9
column sql_text for a200
column module for a80
set pages 1000 lines 600 verify off

--spool spcmds92.csv

select * from (
select /*+ ordered use_nl (b st) */
       case
         when &opt=1 then ratio_to_report(buffer_gets) over ()*100
         when &opt=2 then ratio_to_report(disk_reads) over ()*100
	   when &opt=3 then ratio_to_report(cpu_time) over ()*100
	   when &opt=4 then ratio_to_report(elapsed_time) over ()*100
         when &opt=5 then ratio_to_report(parses) over ()*100
         when &opt=6 then ratio_to_report(execs) over ()*100
       end PCT,
      t.* from (
select st.old_HASH_VALUE
      ,e.BUFFER_GETS-nvl(b.BUFFER_GETS,0) BUFFER_GETS
      ,e.DISK_READS-nvl(b.DISK_READS,0) disk_reads
      ,e.parse_calls-nvl(b.parse_calls,0) parses
      ,e.executions-nvl(b.executions,0) execs
	,e.cpu_time-nvl(b.cpu_time,0) cpu_time
	,e.elapsed_time-nvl(b.elapsed_time,0) elapsed_time
	,e.module
      ,substr(trim(st.sql_text),1,200) sql_text
  from stats$sql_summary e
     , stats$sql_summary b
     , stats$sqltext     st
 where b.snap_id(+)         = &snap_inicial
   and b.dbid(+)            = e.dbid
   and b.instance_number(+) = e.instance_number
   and b.old_hash_value(+)      = e.old_hash_value
   and b.address(+)         = e.address
   and b.text_subset(+)     = e.text_subset
   and e.snap_id            = &snap_final
   and e.old_hash_value         = st.old_hash_value
   and e.text_subset        = st.text_subset
   and st.command_type <> 47
   and e.executions         > nvl(b.executions,0)
   and st.piece = 0    -- garante apenas uma linha da sqltext por hash
  ) t
  order by pct desc
) where rownum <= decode(&topn,0,25,&topn);


--spool off