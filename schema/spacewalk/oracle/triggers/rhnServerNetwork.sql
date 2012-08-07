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

create or replace trigger
rhn_servernetwork_mod_trig
before insert or update on rhnServerNetwork
for each row
begin
        :new.modified := current_timestamp;
end;
/

create or replace trigger
rhn_servnet_ipaddr_mon_trig
after insert or update on rhnServerNetwork
for each row
begin
	if inserting
		or :old.ipaddr is null and :new.ipaddr is not null
		or :old.ipaddr is not null and :new.ipaddr is null
		or :old.ipaddr <> :new.ipaddr
		or :old.ip6addr is null and :new.ip6addr is not null
		or :old.ip6addr is not null and :new.ip6addr is null
		or :old.ip6addr <> :new.ip6addr then
		update rhn_probe
		set last_update_user = 'IP change',
			last_update_date = current_timestamp
		where (recid, probe_type) in (
			select probe_id, probe_type
			from rhn_check_probe
			where host_id = :new.server_id
		);
	end if;
end;
/

show errors
