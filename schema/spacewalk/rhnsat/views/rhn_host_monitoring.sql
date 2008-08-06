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
select  s.id            recid,
	rhn_server.get_ip_address(s.id)	ip,
        s.name          name,
        s.description   description,
        s.org_id        customer_id,
        '4'             os_id,
        null            asset_id,
        null            last_update_user,
        null            last_update_date
from	rhnServer	s
/

--
--$Log$
--Revision 1.5  2004/11/30 22:29:06  pjones
--bugzilla: 141398 -- make rhn_host_monitoring use rhn_server.get_ip_address()
--
--Revision 1.4  2004/07/19 23:22:02  dfaraldo
--Changed view for RHN_HOST_MONITORING (a.k.a. HOST) table to (1) select
--the 'eth0' interface for all servers, and (2) treat all servers as Linux
--servers (no more "Satellite", i.e. scout, OS id).  This change obsoletes
--the RHN_INTERFACE_MONITORING and RHN_SERVER_MONITORING_INFO tables.
--
--Revision 1.3  2004/05/27 21:40:10  pjones
--bugzilla: none -- reformat, reorder from and where clauses for performance.
--
--Revision 1.2  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.1  2004/04/22 15:25:31  kja
--Added user creation.  Renamed the view for the monitoring hosts table.
--
--Revision 1.1  2004/04/19 21:30:43  kja
--Added foreign keys and views.
--
