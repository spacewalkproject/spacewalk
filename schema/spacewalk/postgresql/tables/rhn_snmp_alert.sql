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
   recid                numeric(12)
                        constraint rhn_snmpa_recid_pk primary key
--                      using index tablespace [[2m_tbs]]
                        ,
   sender_cluster_id    numeric(12)
                        not null
                        constraint rhn_snmp_alert_sat_cluster_fk references rhn_sat_cluster(recid),
    dest_ip             varchar(255)
                        not null,
    dest_port           numeric(5)
                        not null,
    date_generated      date,
    date_submitted      date,
    command_name        varchar(255),
    notif_type          numeric(5),
    op_center           varchar(255),
    notif_url           varchar(255),
    os_name             varchar(128),
    message             varchar(2000),
    probe_id            numeric(12),
    host_ip             varchar(255),
    severity            numeric(5),
    command_id          numeric(12),
    probe_class         numeric(5),
    host_name           varchar(255),
    support_center      varchar(255)
)
  ;

comment on table rhn_snmp_alert 
    is 'snmpa  snmp alerts';

create index rhn_snmp_alrt_scid_idx
on rhn_snmp_alert ( sender_cluster_id )
--  tablespace [[64k_tbs]]
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
