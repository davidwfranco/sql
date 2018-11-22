/* Script to get the minnimal information about a table in oracle */

set lines 160 pages 50000 long 10000

col owner for a15
col table for a30
col tablespace_name for a20
col last_analyzed for a13
col partitioned for a11

var v_usr varchar2(30);

exec :v_usr := '&1';

select dt.owner,
    dt.table_name as "table",
    dt.tablespace_name,
    dt.num_rows,
    dt.blocks,
    dt.avg_row_len,
    to_char(dt.last_analyzed, 'dd/mm/yyyy') as last_analyzed,
    dt.partitioned as "part",
    count(*) as "qnt_part",
    round(sum(ds.bytes)/1024/1024, 2) as "size_mb",
    round(sum(ds.bytes)/1024/1024/1024, 2) as "size_gb"
from dba_tables dt, dba_segments ds
where dt.table_name like upper(:v_usr)
and dt.table_name = ds.segment_name
and dt.owner = ds.owner
group by dt.owner, dt.table_name, 
    dt.tablespace_name, dt.num_rows,
    dt.blocks, dt.avg_row_len, 
    dt.last_analyzed, dt.partitioned
order by dt.owner, dt.table_name
;

