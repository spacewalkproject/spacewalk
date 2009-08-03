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

create or replace
package body rhn_bel
is

   function is_org_paid (
      org_id_in in number
   ) return number is
      cursor paids is
         select   1
         from  rhnPaidOrgs
         where org_id = org_id_in;
   begin
      for paid in paids loop return 1; end loop;
      return 0;
   end;

        function lookup_email_state (
                state_in in varchar2
        ) return number is
                retval number;
        begin
                select id into retval from rhnEmailAddressState where label = state_in;
                return retval;
        exception
                        when no_data_found then
                                rhn_exception.raise_exception('invalid_state');
        end lookup_email_state;

end;
/
show errors;
