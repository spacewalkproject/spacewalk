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
-- this is much more readable with ts=4, enjoy!

create or replace view
rhnChannelNewestPackageView
as
select  cp.channel_id		as channel_id,
		p.name_id			as name_id,
		p.evr_id			as evr_id,
		p.package_arch_id	as package_arch_id,
		p.id				as package_id
from	rhnPackageEVR		pe,
		rhnPackage			p,
		rhnChannelPackage	cp
where	cp.package_id = p.id
		and p.evr_id = pe.id
		and pe.evr = (
			select	max(sq_pe.evr)
			from	rhnChannelPackage sq_cp,
					rhnPackage sq_p,
					rhnPackageEVR sq_pe
			where	1=1
				and sq_cp.channel_id = cp.channel_id
				and sq_cp.package_id = sq_p.id
				and sq_p.name_id = p.name_id
				and sq_pe.id = sq_p.evr_id
		)
;

