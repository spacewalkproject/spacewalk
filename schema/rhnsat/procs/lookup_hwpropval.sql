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
lookup_hwpropval(value_in in varchar2)
return number
deterministic
is
	pragma autonomous_transaction;
	value_id number;
	our_csum number;
begin
	our_csum := adler32(value_in);
	select  id
	into    value_id
	from    rhnHardwarePropValue
	where   csum = our_csum;
										
	return value_id;
exception
	when no_data_found then
		insert into rhnHardwarePropValue (id, value, csum)
			values (rhn_hwpropval_id_seq.nextval,
				value_in, our_csum)
			returning id
			into value_id;
		commit;
		return value_id;
end;
/
show errors

-- $Log$
-- Revision 1.3  2003/08/20 16:39:54  pjones
-- bugzilla: none
--
-- disable hw here too
--
-- Revision 1.2  2003/07/01 23:36:47  misa
-- bugzilla: 84125  Typo
--
-- Revision 1.1  2003/06/19 22:25:17  pjones
-- bugzilla: 84125 -- add the lookup functions, fix build
--
