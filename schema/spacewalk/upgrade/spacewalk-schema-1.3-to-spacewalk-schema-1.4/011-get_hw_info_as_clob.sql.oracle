
create or replace function get_hw_info_as_clob(
	sid in rhnserver.id%TYPE,
	separator in varchar
)
return clob
is
	ret clob;
	tmp varchar2(4000);
begin
	dbms_lob.createtemporary(ret, true); 
	for rec in (
		select m
		from (
			select 1 n, sum(nrcpu) || ' CPUs' m
			from rhncpu where rhncpu.server_id = sid
			union all
			select 2, name||' '||ip_addr||'/'||netmask||' '||hw_addr val
			from rhnservernetinterface
			where rhnservernetinterface.server_id = sid
			)
		order by n, m
		) loop
		if dbms_lob.getlength(ret) > 0 then
			dbms_lob.writeappend(ret, length(separator), separator);
		end if;
		dbms_lob.writeappend(ret, length(rec.m), rec.m);
	end loop;
	return ret;
end;
/

