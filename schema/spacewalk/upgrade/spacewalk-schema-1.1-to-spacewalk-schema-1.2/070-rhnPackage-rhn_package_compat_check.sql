
set serveroutput on

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_PACKAGE_COMPAT_CHECK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'compat in ( 1 , 0 )') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNPACKAGE drop constraint RHN_PACKAGE_COMPAT_CHECK';
			end if;
			execute immediate 'alter table RHNPACKAGE add constraint RHN_PACKAGE_COMPAT_CHECK check (compat in ( 1 , 0 ))';
			dbms_output.put_line('(Re)creating RHN_PACKAGE_COMPAT_CHECK');
		end if;
	end loop;
end;
/

