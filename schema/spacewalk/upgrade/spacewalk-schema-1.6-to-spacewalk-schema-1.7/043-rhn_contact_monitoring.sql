--
-- Copyright (c) 2008--2012 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--
--

create or replace view rhn_contact_monitoring as
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
;

