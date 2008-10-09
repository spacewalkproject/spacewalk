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

create or replace function
channel_name_join(sep_in in varchar2, ch_in in channel_name_t)
return varchar2
deterministic
is
	ret	varchar2(4000);
	i	binary_integer;
begin
	ret := '';
	i := ch_in.first;

	if i is null
	then
		return ret;
	end if;

	ret := ch_in(i);
	i := ch_in.next(i);

	while i is not null
	loop
		ret := ret || sep_in || ch_in(i);
		i := ch_in.next(i);
	end loop;

	return ret;
end;
/

-- $Log$
-- Revision 1.3  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
