-- oracle equivalent source sha1 66f568e1f6d397f23d2afd412ea60541db81150c

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
			select 1 n, sum(nrcpu) || ' CPUs ' || coalesce(to_char(sum(nrsocket), 'FM999'), 'unknown') || ' Sockets' m
			from rhncpu where rhncpu.server_id = sid
			union all
			select 2, ni.name||' '||coalesce(na4.address,'')||'/'||coalesce(na4.netmask,'')||' '||ni.hw_addr val
			from rhnservernetinterface ni,
			     rhnServerNetAddress4 na4
			where ni.server_id = sid
			  and ni.id = na4.interface_id
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

