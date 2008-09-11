--
-- $Id$
--
-- This package holds procedures regarding the user state machine,
-- validating email, and other related tasks
create or replace
package rhn_bel
is

   function is_org_paid (
      org_id_in in number
   ) return number;

        function lookup_email_state (
                state_in in varchar2
        ) return number;

end;
/
show errors;

