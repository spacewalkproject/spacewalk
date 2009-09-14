-- created by Oraschemadoc Mon Aug 31 10:54:35 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNWEBCONTACTENABLED" ("ID", "ORG_ID", "LOGIN", "LOGIN_UC", "PASSWORD", "OLD_PASSWORD", "ORACLE_CONTACT_ID", "CREATED", "MODIFIED", "IGNORE_FLAG") AS 
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
   web_contact wcon
minus
select
   wcd.id,
   wcd.org_id,
   wcd.login,
   wcd.login_uc,
   wcd.password,
   wcd.old_password,
   wcd.oracle_contact_id,
   wcd.created,
   wcd.modified,
   wcd.ignore_flag
from
   rhnWebContactDisabled wcd
 
/
