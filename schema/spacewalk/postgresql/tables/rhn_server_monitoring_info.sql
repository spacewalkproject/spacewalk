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

--host current prod row count = 3709

--NOTE:
--since os_id allows null values in the current schema, this one field
--could be added to rhn_server

create table 
rhn_server_monitoring_info
(
    recid               numeric (12) not null
        		constraint rhn_host_recid_pk primary key
			constraint rhn_host_server_id_fk 
    			references rhnServer ( id ),
--            using index tablespace [[4m_tbs]]

    os_id               numeric (12)
			constraint rhn_host_server_name_fk 
    			references rhn_os ( recid )
)
  ;

comment on table rhn_server_monitoring_info 
    is 'host   additional fields to rhn_server for monitoring servers';

--
--Revision 1.4  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.3  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.2  2004/04/20 22:50:09  kja
--Renamed rhn_monitoring_interface as rhn_interface_monitoring for a bit
--of consistency.  Pared down rhn_server_monitoring_info to the minimum
--essentials for triumph.  Added foreign keys to both rhn_interface_monitoring
--and rhn_server_monitoring_info.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--
--
--
