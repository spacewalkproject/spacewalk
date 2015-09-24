-- oracle equivalent source sha1 9ab6626fe584e046eb4b9633f8a5e35f0e9f914d
-- retrieved from ./1235561447/a7740e6945947b753ef3359998c3a103d464f765/schema/spacewalk/rhnsat/procs/delete_channel.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
-- This deletes a channel.  All codepaths which delete channels should hit this

create or replace
function delete_channel (
        channel_id_in in numeric
) returns void as
$$
begin
        delete from rhnChannelPackage where channel_id = channel_id_in;
        delete from rhnChannelErrata where channel_id = channel_id_in;
        delete from rhnServerChannel where channel_id = channel_id_in;
        delete from rhnRegTokenChannels where channel_id = channel_id_in;
        delete from rhnDistChannelMap where channel_id = channel_id_in;
        delete from rhnChannelFamilyMembers where channel_id = channel_id_in;
        delete from rhnServerProfilePackage where server_profile_id in (
            select id from rhnServerProfile where base_channel = channel_id_in
        );
        delete from rhnServerProfile where base_channel = channel_id_in;
        delete from rhnChannel where id = channel_id_in;
end;
$$ language plpgsql;


