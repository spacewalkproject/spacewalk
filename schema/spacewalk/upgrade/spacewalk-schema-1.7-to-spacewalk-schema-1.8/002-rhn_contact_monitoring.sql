drop view rhn_contact_monitoring;
create or replace view rhn_contact_monitoring as
select	u.id			as recid,
	u.org_id		as customer_id,
	wupi.last_name		as contact_last_name,
	wupi.first_names	as contact_first_name,
	wupi.email          as email_address,
	u.login			as username,
	u.password		as password,
	1			as schedule_id,
	'GMT' || ''			as preferred_time_zone
from
	web_user_personal_info wupi,
	web_contact u
where	u.id = wupi.web_user_id
;
