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
-- $Id$
--
-- because I love you all so much, ts=4
--
-- inputs are thus:
-- contact_id_in: web_contact.id for the user
-- org_ok_in: are duplicates within your org ok ('Y' yes, 'N' no)
-- email_in: the address to be checked.
--
-- returns 1 if you can use the address, 0 if you can't.

create or replace function
check_email_uniqueness (
	email_in in varchar2
)
return number
is
	cursor sources(email_cin in varchar2) is
		select	1
		from	web_user_personal_info	wupi
		where	wupi.email = email_cin;
begin
	for source in sources(email_in)
	loop
		return 0;
	end loop;
	return 1;
end;
/
show errors

-- $Log$
-- Revision 1.4  2002/12/16 20:43:19  pjones
-- personal info only, case sensitive
--
-- Revision 1.3  2002/12/13 16:49:43  pjones
-- use email_uc
--
-- Revision 1.2  2002/12/13 16:01:02  pjones
-- ok, so we don't know contact/org when we want to check.  now it just takes
-- email address
--
-- Revision 1.1  2002/12/12 20:55:20  pjones
-- This tries to see if a submitted email address is allowed to be used
--
