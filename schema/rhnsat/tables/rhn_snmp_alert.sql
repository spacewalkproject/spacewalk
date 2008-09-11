--
--$Id$
--
--

--snmp_alert current prod row count = 0
create table 
rhn_snmp_alert
(
   recid                number   (12)
        constraint rhn_snmpa_recid_nn not null
        constraint rhn_snmpa_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    sender_cluster_id   number   (12)
        constraint rhn_snmpa_send_clust_id_nn not null,
    dest_ip             varchar2 (255)
        constraint rhn_snmpa_dest_ip_nn not null,
    dest_port           number   (5)
        constraint rhn_snmpa_dest_port_nn not null,
    date_generated      date,
    date_submitted      date,
    command_name        varchar2 (255),
    notif_type          number   (5),
    op_center           varchar2 (255),
    notif_url           varchar2 (255),
    os_name             varchar2 (128),
    message             varchar2 (2000),
    probe_id            number   (12),
    host_ip             varchar2 (255),
    severity            number   (5),
    command_id          number   (12),
    probe_class         number   (5),
    host_name           varchar2 (255),
    support_center      varchar2 (255)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_snmp_alert 
    is 'snmpa  snmp alerts';

alter table rhn_snmp_alert
    add constraint rhn_snmp_alert_sat_cluster_fk
    foreign key ( sender_cluster_id )
    references rhn_sat_cluster( recid );

create index rhn_snmp_alrt_scid_idx
on rhn_snmp_alert ( sender_cluster_id )
   tablespace [[64k_tbs]]
   nologging
   storage ( pctincrease 1 freelists 16 )
   initrans 32;

create sequence rhn_snmp_alert_recid_seq;

--$Log$
--Revision 1.5  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.4  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.3  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.2  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.1  2004/04/16 19:51:58  kja
--More monitoring schema.
--
--
--$Id$
--
--
