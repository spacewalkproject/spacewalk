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

--service_probe_origins current prod row count = 22088
create table 
rhn_service_probe_origins
(
    service_probe_id    number   (12)
        constraint rhn_srvpo_serv_p_id_nn not null,
    origin_probe_id     number   (12),
    decoupled           char     (1) default '0'
        constraint rhn_srvpo_decoupled_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_service_probe_origins 
    is 'srvpo  mapping from a replicated service probe to the check suite probe it was copied from.  uq instead of pk because need to set origin_probe_id to null!!!';

create unique index rhn_srvpo_serv_pr_id_orig_uq 
    on rhn_service_probe_origins ( service_probe_id, origin_probe_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

 create unique index rhn_srvpo_serv_orig_pr_id_uq
    on rhn_service_probe_origins ( origin_probe_id, service_probe_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_service_probe_origins 
    add constraint rhn_srvpo_serv_pr_id_orig_uq 
    unique ( service_probe_id, origin_probe_id );

alter table rhn_service_probe_origins
    add constraint rhn_srvpo_chkpb_orig_pr_id_fk
    foreign key ( origin_probe_id )
    references rhn_check_suite_probe( probe_id )
    on delete cascade;

alter table rhn_service_probe_origins
    add constraint rhn_srvpo_pr_serv_pr_fk
    foreign key ( service_probe_id )
    references rhn_probe( recid )
    on delete cascade;

--
--Revision 1.5  2004/05/19 02:16:25  kja
--Fixed syntax issues.
--
--Revision 1.4  2004/05/12 22:58:17  kja
--Replace redundant table rhn_check_suite_member_probes with rhn_check_suite_probe.  Bug 109152.  Dropping incorrect "rhn_comman."
--
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
--
--
--
--
