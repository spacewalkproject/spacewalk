--
--$Id$
--
--

--host current prod row count = 3709

--NOTE:
--since os_id allows null values in the current schema, this one field
--could be added to rhn_server

create table 
rhn_server_monitoring_info
(
    recid               number (12)
        constraint rhn_host_recid_nn not null
        constraint rhn_host_recid_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    os_id               number (12)
)
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_server_monitoring_info 
    is 'host   additional fields to rhn_server for monitoring servers';

alter table rhn_server_monitoring_info
    add constraint rhn_host_server_id_fk
    foreign key ( recid )
    references rhnServer ( id );

alter table rhn_server_monitoring_info
    add constraint rhn_host_server_name_fk
    foreign key ( os_id )
    references rhn_os ( recid );

--$Log$
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
--$Id$
--
--
