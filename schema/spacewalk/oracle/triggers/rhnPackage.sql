
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

create or replace trigger
rhn_package_mod_trig
before insert or update on rhnPackage
for each row
begin
	-- when we do a sat sync, we use last_modified to keep track
	-- of the upstream modification date.  So if we're setting
	-- it explicitly, don't override with sysdate.  But if we're
	-- not changing it, then this is a genuine update that needs
	-- tracking.
	--
	-- we're not using is_satellite() here instead, because we
	-- might want to use this to keep webdev in sync.
	if :new.last_modified = :old.last_modified then
		:new.last_modified := sysdate;
	end if;       
	:new.modified := sysdate;
end;
/
show errors
