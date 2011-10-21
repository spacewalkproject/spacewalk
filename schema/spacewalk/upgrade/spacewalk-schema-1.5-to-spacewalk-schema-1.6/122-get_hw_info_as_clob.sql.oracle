
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
			select 2, ni.name||' '||na4.address||'/'||na4.netmask||' '||ni.hw_addr val
			from rhnservernetinterface ni,
			     rhnServerNetAddress4 na4
			where ni.server_id = sid
			  and ni.id = na4.interface_id
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
