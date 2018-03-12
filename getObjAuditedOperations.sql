var tbs_name varchar2(30);
var tbs_name varchar2(30);
var tbs_name varchar2(19);
var tbs_name varchar2(19);

exec :username := upper('&1');
exec :obj_name := upper('&2');
exec :begin_date := upper('&3');
exec :end_date := upper('&4');

select dat.username, 
       dat.to_char(timestamp, 'dd/mm/yyyy hh24:mi:ss') as data, 
       dat.obj_name, 
       dat.action, 
       dat.action_name
from dba_audit_trail dat
where username = :username
and obj_name = :obj_name
and timestamp between to_date(:begin_date, 'dd/mm/yyyy hh24:mi') 
                and to_date(:end_date, 'dd/mm/yyyy hh24:mi')
and action_name <> upper('select')
order by timestamp
;

/*

desc dba_audit_trail

Name               
-------------------
OS_USERNAME        
USERNAME           
USERHOST           
TERMINAL           
TIMESTAMP          
OWNER              
OBJ_NAME           
ACTION             
ACTION_NAME        
NEW_OWNER          
NEW_NAME           
OBJ_PRIVILEGE      
SYS_PRIVILEGE      
ADMIN_OPTION       
GRANTEE            
AUDIT_OPTION       
SES_ACTIONS        
LOGOFF_TIME        
LOGOFF_LREAD       
LOGOFF_PREAD       
LOGOFF_LWRITE      
LOGOFF_DLOCK       
COMMENT_TEXT       
SESSIONID          
ENTRYID            
STATEMENTID        
RETURNCODE         
PRIV_USED          
CLIENT_ID          
ECONTEXT_ID        
SESSION_CPU        
EXTENDED_TIMESTAMP 
PROXY_SESSIONID    
GLOBAL_UID         
INSTANCE_NUMBER    
OS_PROCESS         
TRANSACTIONID      
SCN                
SQL_BIND           
SQL_TEXT           
OBJ_EDITION_NAME   
DBID               

*/