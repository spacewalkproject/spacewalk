-- created by Oraschemadoc Fri Jan 22 13:40:48 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNWEBCONTACTDISABLED" ("ID", "ORG_ID", "LOGIN", "LOGIN_UC", "PASSWORD", "OLD_PASSWORD", "ORACLE_CONTACT_ID", "CREATED", "MODIFIED", "IGNORE_FLAG") AS
  select
   wcon.id,
   wcon.org_id,
   wcon.login,
   wcon.login_uc,
   wcon.password,
   wcon.old_password,
   wcon.oracle_contact_id,
   wcon.created,
   wcon.modified,
   wcon.ignore_flag
from
   rhnWebContactChangeLog   wccl,
   rhnWebContactChangeState wccs,
   web_contact              wcon
where wccl.change_state_id = wccs.id
   and wccs.label = 'disabled'
   and wccl.web_contact_id = wcon.id
   and wccl.date_completed =
              (select max(wccl_exists.date_completed)
                 from rhnWebContactChangeLog   wccl_exists
                where wccl.web_contact_id = wccl_exists.web_contact_id)
 
/
