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
-- This package holds procedures regarding the user state machine,
-- validating email, and other related tasks

create schema rhn_bel;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_bel,' || setting where name = 'search_path';

create or replace function is_org_paid (org_id_in in numeric) returns numeric as
$$
declare
      paids cursor for
         select   1
         from  rhnPaidOrgs
         where org_id = org_id_in;

     paids_curs_1 numeric;
   begin

     open paids;
     loop
	fetch paids into paids_curs_1;
	exit when not found;
	return 1;
     end loop;
   
            return 0;
   end;
$$ language plpgsql;

create or replace function lookup_email_state (
                state_in in varchar
        ) returns numeric as
        $$
        declare
                retval numeric;
        begin
                select id into retval from rhnEmailAddressState where label = state_in;
        

	if not found then
		perform rhn_exception.raise_exception('invalid_state');
	end if;

	return retval;
end;
$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_bel')+1) ) where name = 'search_path';
