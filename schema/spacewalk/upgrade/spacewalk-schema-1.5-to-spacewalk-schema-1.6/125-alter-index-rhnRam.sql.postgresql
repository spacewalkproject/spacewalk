-- oracle equivalent source sha1 5382865750405facc547315329a739b8ee1fe238

delete from rhnram X
	where server_id in (select server_id from rhnram group by server_id having count(server_id)>1)
	 and id<(select max(id) from rhnram Y where X.server_id=Y.server_id group by server_id having count(server_id)>1);

drop index rhn_ram_sid_idx;

create unique index rhn_ram_sid_uq on rhnRam(server_id);
