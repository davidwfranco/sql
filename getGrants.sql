-- Get all grants of a specific user, could be done with the get_ddl to, but this way is easier to 
-- adapt from getting the grants of a user to a table, role or etc.

var v_owner varchar2(30);

exec :v_owner := '&1';

select 'grant '||granted_role||' to '||grantee||';' 
  from dba_role_privs 
 where grantee in (:v_owner)
union all
select 'grant '||privilege||' to '||grantee||';' 
 from dba_sys_privs 
where grantee in (:v_owner)
union all
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||';' 
  from dba_tab_privs 
 where grantee in (:v_owner)
;

exit
