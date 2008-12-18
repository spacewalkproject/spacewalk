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

--snmp_alert current prod row count = 0
create table 
rhn_snmp_alert
(
   recid                number   (12)
        constraint rhn_snmpa_recid_nn not null
        constraint rhn_snmpa_recid_pk primary key
            using index tablespace [[2m_tbs]]
            ,
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
    enable row movement
  ;

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
  ;

create sequence rhn_snmp_alert_recid_seq;

--
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
--
--
--
