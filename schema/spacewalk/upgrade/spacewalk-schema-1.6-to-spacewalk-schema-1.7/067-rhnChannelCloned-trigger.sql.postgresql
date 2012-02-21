-- oracle equivalent source sha1 a1ede433726aac1e44f259d52fddeb6db6f53c4c
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

create or replace function rhn_channel_cloned_comps_trig_fun() returns trigger
as
$$
begin
	new.modified := current_timestamp;

	if tg_op = 'INSERT' then
		-- if there are not comps in the cloned channel by now,
		-- we shall clone comps from the original channel
		insert into rhnChannelComps
			( id, channel_id, relative_filename,
				last_modified, created, modified )
		select nextval('rhn_channelcomps_id_seq'), new.id, relative_filename,
				current_timestamp, current_timestamp, current_timestamp
		from rhnChannelComps
		where channel_id = new.original_id
			and not exists (
				select 1
				from rhnChannelComps x
				where x.channel_id = new.id
			);
	end if;
        return new;
end;
$$
language plpgsql;


drop trigger rhn_channel_cloned_comps_trig on rhnChannelCloned;;

create trigger
rhn_channel_cloned_comps_trig
before insert or update on rhnChannelCloned
for each row
execute procedure rhn_channel_cloned_comps_trig_fun();
