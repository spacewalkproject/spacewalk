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

-- semantics of this view are much different from what the old
-- documentation said, and were before I rewrote it.  The critical
-- change was the "where exists" clause, which means we can never
-- not have any permissions if we show up here.

-- That makes it not so special any more.

create or replace view rhnChannelFamilyOverview as
select	pcf.org_id				as org_id,
	f.id					as id,
	f.name					as name,
	f.product_url				as url,
	f.label					as label,
	coalesce(pcf.current_members,0)		as current_members,
	pcf.max_members				as max_members,
	coalesce(pcf.fve_current_members,0)		as fve_current_members,
	pcf.fve_max_members				as fve_max_members,
	1					as has_subscription
from	rhnChannelFamily			f,
	rhnPrivateChannelFamily			pcf
where	pcf.channel_family_id = f.id;

