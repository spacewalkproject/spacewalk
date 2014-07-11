
--
-- Copyright (c) 2008--2014 Red Hat, Inc.
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
rhn_kstree_mod_trig
before insert or update on rhnKickstartableTree
for each row
begin
     -- Basically if we're changing something other than cobbler_id,
     -- cobbler_xen_id, and last_modified - or if last_modified is
     -- explicity set to null. Gets complicated because we have
     -- to allow for the possibility of the ids being null
     if ((not :old.cobbler_id is null and :new.cobbler_id = :old.cobbler_id) or
            (:old.cobbler_id is null and :new.cobbler_id is null)) and
        ((not :old.cobbler_xen_id is null and :new.cobbler_xen_id = :old.cobbler_xen_id) or
            (:old.cobbler_xen_id is null and :new.cobbler_xen_id is null)) and
        (:new.last_modified = :old.last_modified) or
        (:new.last_modified is null ) then
             :new.last_modified := current_timestamp;
     end if;

	:new.modified := current_timestamp;
end rhn_kstree_mod_trig;
/
show errors
