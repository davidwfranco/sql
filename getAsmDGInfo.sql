-- Get total size and free space of asm diskgroups

SET LINES 180
SET PAGES 9999
SET LONG 100000
set sqlbl on
alter session set nls_numeric_characters=',.';

select name, 
       round(free_mb/1024, 2) as free_gb, 
       round(total_mb/1024, 2) as total_gb, 
       round(free_mb/total_mb*100, 2) as percentage 
  from v$asm_diskgroup;