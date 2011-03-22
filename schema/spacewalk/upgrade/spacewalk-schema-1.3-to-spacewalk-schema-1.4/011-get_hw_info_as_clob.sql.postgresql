-- oracle equivalent source sha1 4a627f5b31efb66c684dd14f0514e25a5ace94f2

create or replace function get_hw_info_as_clob(
	sid in rhnserver.id%TYPE,
	separator in varchar
)
returns text
as
$$
declare
	ret text;
	rec record;
begin
	for rec in (
		select m
		from (
			select 1 n, sum(nrcpu) || ' CPUs' m
			from rhncpu where rhncpu.server_id = sid
			union all
			select 2, name||' '||coalesce(ip_addr,'')||'/'||coalesce(netmask,'')||' '||hw_addr val
			from rhnservernetinterface
			where rhnservernetinterface.server_id = sid
			) X
		order by n, m
		) loop
		if ret is null then
			ret := rec.m;
		else
			ret := ret || separator || rec.m;
		end if;
	end loop;
	return ret;
end;
$$ language plpgsql;

