-- Drop all objects of a given schema
-- Thanks to Lucas Bernardini for the script wireframe

PROMPT INFO: BEGIN cleanSchema.sql

var v_owner varchar2(30);

exec :v_owner := '&1';

set serveroutput on size unlimited verify off

PROMPT INFO: Object count BEFORE cleaning the schema

select object_type, count(*)
  from dba_objects
 where owner = upper(:v_owner)
 group by object_type
;

declare
    cmd varchar2(200);

    cursor tables is 
        select t.owner, t.table_name
          from dba_tables t
         where t.owner = upper(:v_owner)
           and t.table_name not in (select object_name 
                                      from dba_objects 
                                     where owner = t.owner 
                                       and object_type = 'MATERIALIZED VIEW');

    cursor miscObjects is 
        select object_type, owner, object_name
          from dba_objects
         where object_type not in ('TABLE', 'INDEX', 'TRIGGER', 'LOB', 'PACKAGE BODY', 'JOB', 'SCHEDULE', 'DATABASE LINK')
           and object_type not like '%LINK%'
           and object_type not like '%PARTITION%'
           and owner = upper(:v_owner)
         order by 1;

    cursor pkgs is 
        select object_type, owner, object_name
          from dba_objects
         where object_type = 'PACKAGE BODY'
           and owner = upper(:v_owner)
         order by 1;

    cursor jobs is 
        select owner, object_name
          from dba_objects
         where object_type = 'JOB'
           and owner = upper(:v_owner)
         order by 1;

    cursor schedules is 
        select owner, object_name
          from dba_objects
         where object_type = 'SCHEDULE'
           and owner = upper(:v_owner)
         order by 1;
begin
    dbms_output.put_line('INFO: Dropping objects from schema ' || :v_owner);
    dbms_output.put_line('INFO: Dropping tables...');
    for tbl in tables loop
        begin
            --execute immediate 'drop table '||tbl.owner||'.'||tbl.table_name||' cascade constraints purge';
            dbms_output.put_line('drop table '||tbl.owner||'.'||tbl.table_name||' cascade constraints purge');
        exception
            when no_data_found then
                dbms_output.put_line('ERROR: Drop failed on Table: '||tbl.owner||'.'||tbl.table_name||' --> '|| sqlerrm);
        end;
    end loop;
    dbms_output.put_line('INFO: Done.');

    dbms_output.put_line('INFO: Dropping other objects...');
    for obj in miscObjects loop
        begin
            --execute immediate 'drop '||obj.object_type||' '||obj.owner||'.'||obj.object_name;
            dbms_output.put_line('drop '||obj.object_type||' '||obj.owner||'.'||obj.object_name);
        exception
            when no_data_found then
                dbms_output.put_line('ERROR: Drop failed on '||obj.object_type||': '||obj.owner||'.'||obj.object_name||' --> '|| sqlerrm);
        end;
    end loop;
    dbms_output.put_line('INFO: Done.');

    dbms_output.put_line('INFO: Dropping Packages...');
    for pkg in pkgs loop
        begin
            --execute immediate 'drop '||pkg.object_type||' '||pkg.owner||'.'||pkg.object_name;
            dbms_output.put_line('drop '||pkg.object_type||' '||pkg.owner||'.'||pkg.object_name);
        exception
            when no_data_found then
                dbms_output.put_line('ERROR: Drop failed on '||pkg.object_type||': '||pkg.owner||'.'||pkg.object_name||' --> '|| sqlerrm);
        end;
    end loop;
    dbms_output.put_line('INFO: Done.');

    dbms_output.put_line('INFO: Dropping jobs...');
    for job in jobs loop
        begin
            --dbms_scheduler.drop_job(job.owner||'.'||job.object_name);
            dbms_output.put_line('dbms_scheduler.drop_job('||job.owner||'.'||job.object_name||')');
        exception
            when no_data_found then
                dbms_output.put_line('ERROR: Drop failed on JOB: '||job.owner||'.'||job.object_name||' --> '|| sqlerrm);
        end;
    end loop;
    dbms_output.put_line('INFO: Done.');

    dbms_output.put_line('INFO: Dropping schedules...');
    for schedule in schedules loop
        begin
            --dbms_scheduler.drop_schedule(schedule.owner||'.'||schedule.object_name);
            dbms_output.put_line('dbms_scheduler.drop_schedule('||schedule.owner||'.'||schedule.object_name||')');
        exception
            when no_data_found then
                dbms_output.put_line('ERROR: Drop failed on SCHEDULE: '||schedule.owner||'.'||schedule.object_name||' --> '|| sqlerrm);
        end;
    end loop;
    dbms_output.put_line('INFO: Done.');
end;
/

PROMPT INFO: Object count AFTER cleaning the schema

select object_type, count(*)
  from dba_objects
 where owner = upper(:v_owner)
 group by object_type
;
 
PROMPT INFO: END cleanSchema.sql