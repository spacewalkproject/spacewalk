
set serveroutput on

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'ks_type in (''wizard'',''raw'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_TYPE_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_TYPE_CK check (ks_type in (''wizard'',''raw'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_TYPE_CK');
		end if;
	end loop;
end;
/

