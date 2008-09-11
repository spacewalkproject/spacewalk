--
-- $Id$
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
