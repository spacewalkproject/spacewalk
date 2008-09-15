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
-- $Id$
--

create or replace view
rhnChannelPackageOverview
(
    	channel_id,
	name_id,
	evr
)
as
select  cp.channel_id,
	p.name_id,
	max(p_evr.evr)
from
	rhnPackageEVR p_evr,
	rhnPackage p,
	rhnChannelPackage cp
where
    	cp.package_id = p.id
    and p.evr_id = p_evr.id
group by cp.channel_id, p.name_id
/

-- $Log$
-- Revision 1.2  2002/05/15 21:30:09  pjones
-- id/log
--
