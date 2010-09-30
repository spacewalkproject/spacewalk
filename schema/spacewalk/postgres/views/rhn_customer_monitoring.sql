-- oracle equivalent source sha1 09ad5a18270ce086e9d71e895d1daf1952aa1e01
-- retrieved from ./1240273396/cea26e10fb65409287d4579c2409403b45e5e838/schema/spacewalk/oracle/views/rhn_customer_monitoring.sql
--
-- Copyright (c) 2008 Red Hat, Inc.
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

create or replace view rhn_customer_monitoring as
select	org.id			as recid,
	org.name		as description,
	1			as schedule_id,	--24 x 7
	0			as def_ack_wait,
	1			as def_strategy,	--Broadcast, No Ack
	'GMT'::varchar		as preferred_time_zone,
	0			as auto_update	--Windows only
from
	web_customer org
--where	1=1
--	and some logic here to check for entitlements?
;

