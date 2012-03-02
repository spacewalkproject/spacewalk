-- oracle equivalent source sha1 460bbe35116b8140bc06558e3a378c70141899db

--update pg_setting
update pg_settings set setting = 'rhn_server,' || setting where name = 'search_path';

    create or replace function bulk_set_custom_value(
    	key_label_in in varchar,
	value_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    )
    returns integer
    as $$
    declare
        i integer;
        server record;
    begin
        i := 0;
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	) loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	perform rhn_server.set_custom_value(server.element, set_uid_in, key_label_in, value_in);
            i := i + 1;
	    end if;
	end loop;
    return i;
    end$$ language plpgsql;

    create or replace function bulk_snapshot_tag(
    	org_id_in in numeric,
        tagname_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    ) returns void
    as $$
    declare
        server record;
    	snapshot_id numeric;
    begin
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	    ) loop
	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	    select max(id) into snapshot_id
	    	    from rhnSnapshot
	    	    where server_id = server.element;

	    	    if snapshot_id is null then
		    	perform rhn_server.snapshot_server(server.element, 'tagging system:  ' || tagname_in);
			
			select max(id) into snapshot_id
			from rhnSnapshot
			where server_id = server.element;
		    end if;
		 
		-- now have a snapshot_id to work with...
		begin
		    perform rhn_server.tag_snapshot(snapshot_id, org_id_in, tagname_in);
		exception
		    when UNIQUE_VIOLATION
		    	then
			-- do nothing, be forgiving...
			null;
		end;
	    end if;
	end loop;    
    end$$ language plpgsql;

    create or replace function bulk_snapshot(
    	reason_in in varchar,
	set_label_in in varchar,
	set_uid_in in numeric
    ) returns void
    as $$
    declare
        server record;
    begin
        for server in (
           SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_uid_in
	    ) loop
    	    if rhn_server.system_service_level(server.element, 'provisioning') = 1 then
	    	perform rhn_server.snapshot_server(server.element, reason_in);
	    end if;
	end loop;
    end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_server')+1) ) where name = 'search_path';

