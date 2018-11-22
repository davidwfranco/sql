set lines 1000 pages 0 long 10000 feedback off

var v_owner varchar2(30);

exec :v_owner := '&1';

spool "fks-indexes-status.TXT"

select 'status;table_name;fk_name;fk_columns;index_name;index_columns' from dual;

select '"' ||
  nvl2(b.table_name,'indexed','unindexed') || '";"' ||
  a.table_name  || '";"' || 
  a.constraint_name || '";"' ||
  a.fk_columns || '";"' ||
  b.index_name || '";"' ||
  b.index_columns || '"'
from ( select a.owner,
          a.table_name,
          a.constraint_name,
          listagg(a.column_name, ',') within group (order by a.position) fk_columns
      from dba_cons_columns a,
          dba_constraints b
      where a.constraint_name = b.constraint_name
      and b.constraint_type = 'R'
      and  a.owner = b.owner
      and a.owner = upper(:v_owner)
      group by a.owner, a.table_name, a.constraint_name
    ) a
    ,( select table_name,
          index_name,
          listagg(c.column_name, ',') within group (order by c.column_position) index_columns
      from dba_ind_columns c
      group by table_name, index_name
    ) b
where a.table_name = b.table_name(+)
and a.owner = upper(:v_owner)
and b.index_columns(+) like a.fk_columns || '%'
order by 1 desc
;