col killcmd for a100

var v_usr varchar2(30);

exec :v_usr := '&1';

select 'ALTER SYSTEM KILL SESSION ''' || s.SID || ',' || s.SERIAL# || ',@' || S.INST_ID || ''' IMMEDIATE;' killcmd
from gv$SESSION s
where s.USERNAME IN (:v_usr)
;
