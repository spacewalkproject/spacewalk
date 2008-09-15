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
--$Id$
--
--

--originally from the nolog instance
--deployed_probe current prod row count = 30461
create table 
rhn_deployed_probe
(
    recid                            number   (12)
        constraint rhn_dprob_recid_nn not null
        constraint rhn_dprob_recid_pk primary key
            using index tablespace [[8m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    probe_type                       varchar2 (15)
        constraint rhn_dprob_probe_type_nn not null,
    description                      varchar2 (255),
    customer_id                      number   (12)
        constraint rhn_dprob_cust_id_nn not null,
    command_id                       number   (16)
        constraint rhn_dprob_command_id_nn not null,
    contact_group_id                 number   (12),
    os_id                            number   (12),
    notify_critical                  char     (1),
    notify_warning                   char     (1),
    notify_recovery                  char     (1),
    notify_unknown                   char     (1),
    notification_interval_minutes    number   (16)
        constraint rhn_dprob_notif_int_nn not null,
    check_interval_minutes           number   (16)
        constraint rhn_dprob_check_int_nn not null,
    retry_interval_minutes           number   (16)
        constraint rhn_dprob_retry_int_nn not null,
    max_attempts                     number   (16),
    sat_cluster_id                   number   (12),
    parent_probe_id                  number   (12),
    last_update_user                 varchar2 (40),
    last_update_date                 date
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_deployed_probe is 'dprob  deployed_probe definitions';

create unique index rhn_dprob_recid_probe_type_uq 
    on rhn_deployed_probe ( recid, probe_type )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_dprob_check_command_id_idx 
    on rhn_deployed_probe ( command_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_dprob_customer_id_idx 
    on rhn_deployed_probe ( customer_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_dprob_sat_cluster_id_idx 
    on rhn_deployed_probe ( sat_cluster_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_deployed_probe 
    add constraint dprob_recid_probe_type_uq unique ( recid, probe_type );

--$Log$
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
