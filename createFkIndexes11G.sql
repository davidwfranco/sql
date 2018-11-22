accept username char PROMPT 'DEFINA O USUARIO: '

set lines 1000
set pages 0
set verify off
set timing off
set feedback off
set trimspool on

SPOOL create_missing_index_fk.sql

SELECT 'CREATE INDEX IDX_MISS_'||ROWNUM||' ON '||USUSARIO||'.'||TABELA||'('||COLUNAS||') COMPUTE STATISTICS;' SENTENCA
FROM (
select /*+ ordered */
  distinct n.name  NOME_CONSTRAINT,
  u.name USUSARIO,
  o.name TABELA,
  LISTAGG(c.name, ',')
       WITHIN GROUP (ORDER BY o.name,c.name)
       OVER (PARTITION BY o.name,n.name) COLUNAS
from
  (
    select /*+ ordered */ distinct
      cd.con#,
      cd.obj#
    from
      sys.cdef$  cd,
      sys.tab$  t
    where
      cd.type# = 4 and			-- foriegn key
      t.obj# = cd.robj# and
      bitand(t.flags, 6) = 0 and	-- table locks enabled
      not exists (			-- not indexed
	select
	  null
	from
	  sys.ccol$  cc,
          sys.ind$  i,
	  sys.icol$  ic
	where
          cc.con# = cd.con# and
          i.bo# = cc.obj# and
          bitand(i.flags, 1049) = 0 and 	-- index must be valid
          ic.obj# = i.obj# and
	  ic.intcol# = cc.intcol#
        group by
          i.obj#
        having
          sum(ic.pos#) = (cd.cols * cd.cols + cd.cols)/2
      )
  )  fk,
  sys.obj$  o,
  sys.user$  u,
  sys.ccol$  cc,
  sys.col$  c,
  sys.con$  n
where
  o.obj# = fk.obj# and
--  o.owner# != 0 and			-- ignore SYS
  o.owner# = (select user# from sys.user$ where name=UPPER('&username')) and
  u.user# = o.owner# and
  cc.con# = fk.con# and
  c.obj# = cc.obj# and
  c.intcol# = cc.intcol# and
  n.con# = fk.con#)
/

spool off

set pages 1000
set timing on
set feedback on
set trimspool off
set termout on