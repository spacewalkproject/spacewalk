
set serveroutput on

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CNTGP_ROTATE_F_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'rotate_first in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_CONTACT_GROUPS drop constraint RHN_CNTGP_ROTATE_F_CK';
			end if;
			execute immediate 'alter table RHN_CONTACT_GROUPS add constraint RHN_CNTGP_ROTATE_F_CK check (rotate_first in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_CNTGP_ROTATE_F_CK');
		end if;
	end loop;
end;
/

