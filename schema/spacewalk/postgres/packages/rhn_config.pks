--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--

create schema rhn_config;


-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_config,' || setting where name = 'search_path';

Create or replace function prune_org_configs
(
    org_id_in in numeric,
    total_in in numeric
)
returns numeric
as $$    
begin
    return 0;
end;
$$ LANGUAGE 'plpgsql';

create or replace function delete_revision
(
    config_revision_id_in in numeric,
    org_id_in in numeric 
)
returns void
as $$
begin
end;
$$ LANGUAGE 'plpgsql';

create or replace function get_latest_revision
(
    config_file_id_in in numeric
) 
returns numeric
as $$
begin
    return 0;
end;
$$ LANGUAGE 'plpgsql';

create or replace function insert_file
(
    config_channel_id_in in numeric,
    name_in in varchar
)
returns numeric
as $$
begin
    return 0;
end;
$$ LANGUAGE 'plpgsql';

create or replace function delete_file(config_file_id_in in numeric)
returns void
as $$
begin
end;
$$ LANGUAGE 'plpgsql';

create or replace function insert_channel
(
    org_id_in in numeric,
    type_in in varchar,
    name_in in varchar,
    label_in in varchar,
    description_in in varchar
)
returns numeric
as $$
begin
    return 0;
end;
$$ LANGUAGE 'plpgsql';

create or replace function delete_channel(config_channel_id_in in numeric)
returns void
as $$
begin
end;
$$ LANGUAGE 'plpgsql';

update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_config')+1) ) where name = 'search_path';
