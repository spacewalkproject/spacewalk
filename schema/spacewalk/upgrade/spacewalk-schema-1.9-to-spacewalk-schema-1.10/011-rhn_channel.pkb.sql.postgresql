-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8
--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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
--
--
--

-- create schema rhn_channel;

--update pg_setting
update pg_settings set setting = 'rhn_channel,' || setting where name = 'search_path';

    create or replace function set_comps(channel_id_in in numeric, path_in in varchar, timestamp_in in varchar) returns void
    as $$
    declare
    row record;
    begin
        for row in (
            select relative_filename, last_modified
            from rhnChannelComps
            where channel_id = channel_id_in
            ) loop
            if row.relative_filename = path_in
                and row.last_modified = to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS') then
                return;
            end if;
        end loop;
        delete from rhnChannelComps
        where channel_id = channel_id_in;
        insert into rhnChannelComps (id, channel_id, relative_filename, last_modified, created, modified)
        values (sequence_nextval('rhn_channelcomps_id_seq'), channel_id_in, path_in, to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS'), current_timestamp, current_timestamp);
    end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_channel')+1) ) where name = 'search_path';
