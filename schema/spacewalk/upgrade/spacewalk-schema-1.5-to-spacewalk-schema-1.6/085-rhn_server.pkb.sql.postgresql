-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

--update pg_setting
update pg_settings set setting = 'rhn_server,' || setting where name = 'search_path';

    create or replace function update_needed_cache(
        server_id_in in numeric
	) returns void as $$
    begin
        delete from rhnServerNeededCache
         where server_id = server_id_in;
        insert into rhnServerNeededCache
               (server_id, errata_id, package_id)
               (select distinct server_id, errata_id, package_id
                  from rhnServerNeededView
                 where server_id = server_id_in);
	end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_server')+1) ) where name = 'search_path';
