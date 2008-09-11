--
-- $Id$
--
--

create or replace view rhn_customer_monitoring as
select	org.id			recid,
	org.name		description,
--	null			ssh_password,
--	null			deleted,
--	null			last_update_user,
--	null			last_update_date,
	1			schedule_id,	--24 x 7
				--references rhn_schedules(recid)
	0			def_ack_wait,
	1			def_strategy,	--Broadcast, No Ack
				--references rhn_strategies(recid)
	'GMT'			preferred_time_zone,
				--references rhn_time_zone_names(java_id)
--	0			security_service_vulnerability,
--	0			security_service_management,
	0			auto_update	--Windows only
--	'external-paying'	type,
from
	web_customer org
where	1=1
--	and some logic here to check for entitlements?
/

--
--$Log$
--Revision 1.4  2005/02/22 17:57:43  jslagle
--bz #140368
--Drop schedule_zone_id column.
--
--Revision 1.3  2004/05/27 21:33:10  pjones
--bugzilla: none -- reformat, change web_customer's alias to the more idiomatic
--"org"
--
--Revision 1.2  2004/05/27 20:17:38  kja
--tweaks to syntax.
--
--Revision 1.1  2004/04/19 21:30:43  kja
--Added foreign keys and views.
--
