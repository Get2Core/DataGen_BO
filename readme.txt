** Required DB Version

Oracle Database 10g or above

** Data Tablespace creation

col file_name new_value file_name noprint
col bo_file_name new_value bo_file_name noprint

select df.name file_name
from v$datafile df, v$tablespace ts
where df.ts#=ts.ts#
  and ts.name='SYSTEM'
;
select substr('&&file_name',1,instr('&&file_name','\',-1))||'BO01.DBF' bo_file_name from dual;

create tablespace BO datafile '&&bo_file_name' size 4G;

** Undo Tablespace Resize

col file_name new_value file_name noprint
col undo_name new_value undo_name noprint

select value undo_name from v$parameter where name='undo_tablespace';

select df.name file_name
from v$datafile df, v$tablespace ts
where df.ts#=ts.ts#
  and ts.name = '&&undo_name'
;
select substr('&&file_name',1,instr('&&file_name','\',-1))||'BO01.DBF' bo_file_name from dual;

alter database datafile '&&file_name' resize 2G;


** User creation

create user BO identified by bo default tablespace BO;

grant create session to bo;
grant create view to bo;
grant resource to bo;
grant select any table to bo;
grant select any dictionary to bo;
alter user bo quota unlimited on bo;
grant execute on dbms_flashback to bo;
grant execute on dbms_lock to bo;

** How to create data

exec PKG_DATA_GEN.MAIN(random seed value,volume of customer table);

ex> exec PKG_DATA_GEN.MAIN(100,200000);

