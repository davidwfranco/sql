select username 
from dba_users 
where username like '%PERFSTAT%'
;

select min(snap_id) as minSnap, 
    to_char(min(SNAP_TIME), 'dd/mm/yyyy hh24:mi') as minDt, 
    max(snap_id) as maxSnap, 
    to_char(max(SNAP_TIME), 'dd//mm/yyyy hh24:mi') as maxDt,
    count(*) as qntSnap
from STATS$SNAPSHOT
;

select snap_id, 
    to_char(SNAP_TIME, 'dd/mm/yyyy hh24:mi') as snapTime,
    SNAP_LEVEL
from STATS$SNAPSHOT
order by snap_id
;
