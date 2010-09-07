
set serveroutput on

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from user_constraints
		where table_name = 'RHNKICKSTARTSCRIPT'
		) loop
		if i.constraint_type = 'C' and i.search_condition like 'raw_script in%' then
			execute immediate 'alter table RHNKICKSTARTSCRIPT drop constraint ' || i.constraint_name;
		end if;
	end loop;
	execute immediate 'alter table RHNKICKSTARTSCRIPT add constraint RHN_KSSCRIPT_RAWSCRIPT_CK check (raw_script in (''Y'',''N'')) novalidate';
	dbms_output.put_line('(Re)creating RHN_KSSCRIPT_RAWSCRIPT_CK');
end;
/

