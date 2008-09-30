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

create table 
rhn_interface_monitoring
(
    server_id       number
        constraint rhn_monif_server_id_nn not null
        constraint rhn_monif_server_pk primary key
            using index tablespace [[8m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    server_name     varchar (32)   
        constraint rhn_monif_server_name_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_interface_monitoring
   is 'monif  Monitoring interface.  The one entry from rhnservernetinterface to be used for monitoring on a host.';

alter table rhn_interface_monitoring
    add constraint rhn_monif_server_name_fk
    foreign key ( server_id, server_name )
    references rhnServerNetInterface ( server_id, name );

create unique index rhn_int_mont_sid_sname_idx
on rhn_interface_monitoring ( server_id, server_name )
   tablespace [[8m_tbs]]
   nologging
   storage ( pctincrease 1 freelists 16 )
   initrans 32;


--$Log$
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/20 22:50:09  kja
--Renamed rhn_monitoring_interface as rhn_interface_monitoring for a bit
--of consistency.  Pared down rhn_server_monitoring_info to the minimum
--essentials for triumph.  Added foreign keys to both rhn_interface_monitoring
--and rhn_server_monitoring_info.
--
--Revision 1.1  2004/04/19 21:30:43  kja
--Added foreign keys and views.
--
--
--
--
--
