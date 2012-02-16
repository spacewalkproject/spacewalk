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

drop view rhn_customer_monitoring;
create view rhn_customer_monitoring as
select	org.id			as recid,
	org.name		as description,
	1			as schedule_id,	--24 x 7
	0			as def_ack_wait,
	1			as def_strategy,	--Broadcast, No Ack
	'GMT' || ''		as preferred_time_zone,
	0			as auto_update	--Windows only
from
	web_customer org
;

