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

--probe current prod row count = 34038
create table 
rhn_probe
(
    recid                            numeric   (12) not null
        constraint rhn_probe_recid_pk primary key
--            using index tablespace [[8m_tbs]]
            ,
    probe_type                       varchar (15) not null
					constraint rhn_probe_prbtp_probe_type_fk 
    					references rhn_probe_types( probe_type ),
    description                      varchar (255) not null,
    customer_id                      numeric   (12) not null
					constraint rhn_probe_cstmr_customer_id_fk
    					references web_customer( id ),
    command_id                       numeric   (16) not null
					constraint rhn_probe_cmmnd_command_id_fk
    					references rhn_command( recid ),
    contact_group_id                 numeric   (12),
    notify_critical                  char     (1),
    notify_warning                   char     (1),
    notify_unknown                   char     (1),
    notify_recovery                  char     (1),
    notification_interval_minutes    numeric   (16) not null,
    check_interval_minutes           numeric   (16) not null,
    retry_interval_minutes           number   (16) not null,
    max_attempts                     numeric   (16),
    last_update_user                 varchar (40),
    last_update_date                 date,
					constraint rhn_probe_recid_probe_type_uq unique ( recid, probe_type )
--  					using tablespace [[8m_tbs]]

)

  ;

comment on table rhn_probe 
    is 'probe  probe definitions';

create index rhn_probe_check_command_id_idx 
    on rhn_probe ( command_id )
--    tablespace [[8m_tbs]]
  ;

create index rhn_probe_customer_id_idx 
    on rhn_probe ( customer_id )
--    tablespace [[8m_tbs]]
  ;

create index rhn_probe_probe_type_idx 
    on rhn_probe ( probe_type )
--    tablespace [[8m_tbs]]
  ;

create index rhn_probe_contact_grp_idx 
    on rhn_probe ( contact_group_id )
--    tablespace [[8m_tbs]]
  ;
create sequence rhn_probes_recid_seq;

--
--Revision 1.6  2004/07/13 14:13:23  kja
--bugzilla 127588 -- create index on rhn_probe (contact_group_id) to prevent
--full table scan of rhn_probe.
--
--Revision 1.5  2004/06/25 21:42:26  nhansen
--bug 126752: make rhn_probe.description a not null field in the db, since the UI has it as a mandatory param
--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/16 02:21:16  kja
--Corrected index naming.  Removed a bkup table.
--
--Revision 1.1  2004/04/13 22:05:17  kja
--More monitoring schema.
--
--
--
--
--
