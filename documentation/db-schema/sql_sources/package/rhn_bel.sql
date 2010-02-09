-- created by Oraschemadoc Fri Jan 22 13:41:05 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "SPACEWALK"."RHN_BEL"
is

   function is_org_paid (
      org_id_in in number
   ) return number;

        function lookup_email_state (
                state_in in varchar2
        ) return number;

end;
CREATE OR REPLACE PACKAGE BODY "SPACEWALK"."RHN_BEL"
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
