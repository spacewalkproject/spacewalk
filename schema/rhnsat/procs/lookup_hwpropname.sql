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
-- EXCLUDE: all
--

create or replace function
lookup_hwpropname(name_in in varchar2)
return number
deterministic
is
	pragma autonomous_transaction;
	name_id number;
begin
	select  id
	into    name_id
	from    rhnHardwarePropName
	where   name = name_in;

	return name_id;
exception
	when no_data_found then
		insert into rhnHardwarePropName (id, name)
			values (rhn_hwpropname_id_seq.nextval, name_in)
			returning id
			into name_id;
		commit;
		return name_id;
end;
/
show errors

-- $Log$
-- Revision 1.2  2003/08/20 16:39:54  pjones
-- bugzilla: none
--
-- disable hw here too
--
-- Revision 1.1  2003/06/19 22:25:17  pjones
-- bugzilla: 84125 -- add the lookup functions, fix build
--
