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

create or replace view rhn_host_monitoring
(
	recid,
	ip,
	name,
	description,
	customer_id,
	os_id,
	asset_id,
	last_update_user,
	last_update_date
) as
select  s.id            as recid,
	rhn_server.get_ip_address(s.id)	as ip,
        s.name          as name,
        s.description   as description,
        s.org_id        as customer_id,
        '4'             as os_id,
        null            as asset_id,
        null            as last_update_user,
        null            as last_update_date
from	rhnServer	s
;

