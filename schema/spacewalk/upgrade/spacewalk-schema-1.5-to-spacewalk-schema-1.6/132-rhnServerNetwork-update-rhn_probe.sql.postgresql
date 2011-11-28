-- oracle equivalent source sha1 c4740f0347166823c12b86d3fe2f9d73a50b43e0

create or replace function rhn_servnet_ipaddr_mon_trig_fun() returns trigger as
$$
declare
	updateit boolean = false;
begin
	if tg_op ='INSERT' then
		updateit = true;
	elsif tg_op ='UPDATE' then
		if old.ipaddr is null and new.ipaddr is not null
			or old.ipaddr is not null and new.ipaddr is null
			or old.ipaddr <> new.ipaddr
			or old.ip6addr is null and new.ip6addr is not null
			or old.ip6addr is not null and new.ip6addr is null
			or old.ip6addr <> new.ip6addr then
			updateit = true;
		end if;
	end if;
	if updateit then
		update rhn_probe
		set last_update_user = 'IP change',
			last_update_date = current_timestamp
		where (recid, probe_type) in (
			select probe_id, probe_type
			from rhn_check_probe
			where host_id = new.server_id
		);
	end if;
	return new;
end;
$$ language plpgsql;

create trigger
rhn_servnet_ipaddr_mon_trig
after insert or update on rhnServerNetwork
for each row
execute procedure rhn_servnet_ipaddr_mon_trig_fun();

