-- oracle equivalent source sha1 65d5cf349f96759bbaddc9b52807d2216a6c6b91
--
-- Copyright (c) 2011--2012 Red Hat, Inc.

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    create or replace function can_server_consume_fve(server_id_in in numeric) returns numeric
    as $$
    declare
        vi_entries cursor for
            SELECT 1
              FROM rhnVirtualInstance vi
             WHERE vi.virtual_system_id = server_id_in;
        vi_count numeric;

    begin
        FOR vi_entry IN VI_ENTRIES LOOP
            return 1;
        END LOOP;
        RETURN 0;
    end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
