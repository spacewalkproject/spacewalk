-- created by Oraschemadoc Mon Aug 31 10:54:35 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHN_CONTACT_MONITORING" ("RECID", "CUSTOMER_ID", "CONTACT_LAST_NAME", "CONTACT_FIRST_NAME", "EMAIL_ADDRESS", "USERNAME", "PASSWORD", "SCHEDULE_ID", "PREFERRED_TIME_ZONE") AS 
  select	u.id			as recid,
	u.org_id		as customer_id,
	wupi.last_name		as contact_last_name,
	wupi.first_names	as contact_first_name,
	rhn_user.find_mailable_address(u.id)
				as email_address,
	u.login			as username,
	u.password		as password,
	1			as schedule_id,
	'GMT'			as preferred_time_zone
from
	web_user_personal_info wupi,
	web_contact u
where	u.id = wupi.web_user_id
	--  and some logic here to check org id for entitlements?

 
/
