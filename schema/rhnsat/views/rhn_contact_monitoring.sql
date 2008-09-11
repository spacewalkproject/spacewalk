--
-- $Id$
--
--

create or replace view rhn_contact_monitoring as
select	u.id			recid,
	u.org_id		customer_id,
	wupi.last_name		contact_last_name,
	wupi.first_names	contact_first_name,
	rhn_user.find_mailable_address(u.id)
				email_address,
--	null			pager,
	u.login			username,
	u.password		password,
--	null			roles,
--	null			deleted,
--	null			last_update_user,
--	null			last_update_date,
	1			schedule_id,
					--references rhn_schedule(recid)
--	null			num_userid,
--	null			password_question,
--	null			password_answer,
	'GMT'			preferred_time_zone
				--derive from rhnuserinfo.tz_offset ??
				--references rhn_time_zone_names(java_id)
--	null			security_access_vulnerabiliity,
--	null			security_access_management,
--	0			failed_logins,
--	null			privilege_type_name 
				--references rhn_privelege_type(name)
--	null			taserial,
from 
	web_user_personal_info wupi,
	web_contact u
where	1=1
	and u.id = wupi.web_user_id
	--  and some logic here to check org id for entitlements?
/

--
--$Log$
--Revision 1.5  2005/02/22 17:57:43  jslagle
--bz #140368
--Drop schedule_zone_id column.
--
--Revision 1.4  2004/05/28 22:24:53  pjones
--bugzilla: none -- typo fix.
--
--Revision 1.3  2004/05/27 21:32:09  pjones
--bugzilla: none -- reformat the query, use find_mailable_address(),
--join the tables together so we don't get a full cartesian output,
--and reorder the tables for better performance.
--
--Revision 1.2  2004/05/27 20:17:38  kja
--tweaks to syntax.
--
--Revision 1.1  2004/04/19 21:30:43  kja
--Added foreign keys and views.
--
