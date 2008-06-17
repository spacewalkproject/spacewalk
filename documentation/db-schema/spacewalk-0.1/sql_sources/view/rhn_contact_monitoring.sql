-- created by Oraschemadoc Fri Jun 13 14:06:09 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHN_CONTACT_MONITORING" ("RECID", "CUSTOMER_ID", "CONTACT_LAST_NAME", "CONTACT_FIRST_NAME", "EMAIL_ADDRESS", "USERNAME", "PASSWORD", "SCHEDULE_ID", "PREFERRED_TIME_ZONE") AS 
  select	u.id			recid,
	u.org_id		customer_id,
	wupi.last_name		contact_last_name,
	wupi.first_names	contact_first_name,
	rhn_user.find_mailable_address(u.id)
				email_address,
	u.login			username,
	u.password		password,
	1			schedule_id,
	'GMT'			preferred_time_zone
from
	web_user_personal_info wupi,
	web_contact u
where	1=1
	and u.id = wupi.web_user_id
 
/
