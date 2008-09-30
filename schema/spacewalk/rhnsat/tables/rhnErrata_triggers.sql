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
--
--
--

create or replace trigger
rhn_errata_mod_trig
before insert or update on rhnErrata
for each row
begin
     if ( :new.last_modified = :old.last_modified ) or
        ( :new.last_modified is null )  then
        :new.last_modified := sysdate;
     end if;

	  	:new.modified := sysdate;
end rhn_errata_mod_trig;
/
show errors

--
--
-- Revision 1.2  2005/02/10 17:09:45  misa
-- bugzilla: 147534  Fixing the spam problem by properly updating the last_modified field
--
-- Revision 1.1  2004/11/01 21:47:41  pjones
-- bugzilla: none -- rhnErrata's triggers need other tables now
--
