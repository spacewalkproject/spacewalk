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
-- $Id$
--
-- data for rhnUserInfo
--
-- EXCLUDE: all

-- create the dummy records
declare
  cursor uinfo is select id user_id from web_contact;
  nrrec number;
begin
	nrrec := 0;
	for info_rec in uinfo loop
	   insert into rhnUserInfo (user_id) values (info_rec.user_id);
	   nrrec := nrrec + 1;
	   if nrrec > 5000 
	   then
	       commit;
	       nrrec := 0;
	   end if;
	end loop;
end;
/
show errors;
commit;

-- $Log$
-- Revision 1.2  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--


