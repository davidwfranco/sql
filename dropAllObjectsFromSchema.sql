/* ------------------------------------------ */
/*-- Creator: Lucas Bernardini              --*/
/*-- Update: David Franco - 20171112        --*/
/*-- >> Added the error handling           --*/
/* ------------------------------------------ */

undefine owner

set serveroutput on size unlimited

PROMPT '----------> Objects Ini:'
select object_type, count(*)
  from dba_objects
 where owner = upper('&&owner')
 group by object_type;

declare
    cursor c is select 'drop table '||t.owner||'.'||t.table_name||' cascade constraints purge' as cmdtox
                  from dba_tables t
                 where t.owner = upper('&&owner')
                   and t.table_name not in (select object_name from dba_objects where owner = t.owner and object_type = 'MATERIALIZED VIEW');
    cursor o is select 'drop '||object_type||' '||owner||'.'||object_name as cmdtox
                  from dba_objects
                 where object_type not in ('TABLE', 'INDEX', 'TRIGGER', 'LOB', 'PACKAGE BODY', 'JOB', 'SCHEDULE', 'DATABASE LINK')
                   and object_type not like '%LINK%'
                   and object_type not like '%PARTITION%'
                   and owner = upper('&&owner')
                 order by 1;
    cursor p is select 'drop '||object_type||' '||owner||'.'||object_name as cmdtox
                  from dba_objects
                 where object_type = 'PACKAGE BODY'
                   and owner = upper('&&owner')
                 order by 1;
    cursor j is select owner, object_name
                  from dba_objects
                 where object_type = 'JOB'
                   and owner = upper('&&owner')
                 order by 1;
    cursor s is select owner, object_name
                  from dba_objects
                 where object_type = 'SCHEDULE'
                   and owner = upper('&&owner')
                 order by 1;
begin
    dbms_output.put_line('----------> Dropping tables...');
    for i in c loop
        begin
            execute immediate i.cmdtox;
        exception
            when others then
                dbms_output.put_line('Error Dropping Table: ');
                dbms_output.put_line(sqlerrm || ' --> ' || i.cmdtox);
        end;
    end loop;
    dbms_output.put_line('Done.');

    dbms_output.put_line('----------> Dropping objects...');
    for i in o loop
        begin
            execute immediate i.cmdtox;
        exception
            when others then
                dbms_output.put_line('Error Dropping Object: ');
                dbms_output.put_line(sqlerrm || ' --> ' || i.cmdtox);
        end;
    end loop;
    dbms_output.put_line('Done.');

    dbms_output.put_line('----------> Dropping other objects...');
    for i in p loop
        begin
            dbms_scheduler.drop_job(i.owner || '.' || i.object_name);
        exception
            when others then
                dbms_output.put_line('Error Dropping Object: ');
                dbms_output.put_line(sqlerrm || ' --> ' || i.owner || '.' || i.object_name);
        end;
    end loop;
    dbms_output.put_line('Done.');

    dbms_output.put_line(' Dropping jobs...');
    for i in j loop
        begin
            execute immediate i.cmdtox;
        exception
            when others then
                dbms_output.put_line('Error Dropping Job: ');
                dbms_output.put_line(sqlerrm || ' --> ' || i.cmdtox);
        end;
    end loop;
    dbms_output.put_line('Done.');

    dbms_output.put_line('Dropping schedules...');
    for i in s loop
        begin
            dbms_scheduler.drop_schedule(i.owner || '.' || i.object_name);
        exception
            when others then
                dbms_output.put_line('Error Dropping Schedule: ');
                dbms_output.put_line(sqlerrm || ' --> ' || i.owner || '.' || i.object_name);
        end;
    end loop;
    dbms_output.put_line('Done.');
end;
/

PROMPT '----------> Objects Left:'
select object_type, count(*)
  from dba_objects
 where owner = upper('&&owner')
 group by object_type;

undefine owner