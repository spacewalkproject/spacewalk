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

--host_probe current prod row count = 2793
create table 
rhn_host_probe
(
    probe_id        number   (12)
        constraint rhn_hstpb_probe_id_nn not null
        constraint rhn_hstpb_probe_id_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    probe_type      varchar2 (12) default 'host'
        constraint rhn_hstpb_probe_type_nn not null
        constraint rhn_hstpb_probe_type_ck check ( probe_type='host' ),
    host_id         number   (12)
        constraint rhn_hstpb_host_id_nn not null,
    sat_cluster_id  number   (12)
        constraint rhn_hstpb_sat_cl_id_nn not null
)  
    storage ( pctincrease 1 freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_host_probe 
    is 'hstpb  host probe definitions';

create index rhn_hstpb_host_id_idx 
    on rhn_host_probe ( host_id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create index rhn_hstpb_sat_cluster_id_idx 
    on rhn_host_probe ( sat_cluster_id )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_hstpb_pbid_ptype_idx
    on rhn_host_probe ( probe_id, probe_type )
    tablespace [[4m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_host_probe
    add constraint rhn_hstpb_host_id_fk
    foreign key ( host_id )
    references rhnServer( id );

alter table rhn_host_probe
    add constraint rhn_hstpb_probe_probe_id_fk
    foreign key ( probe_id, probe_type )
    references rhn_probe( recid, probe_type )
    on delete cascade;

alter table rhn_host_probe
    add constraint rhn_hstpb_satcl_id_fk
    foreign key ( sat_cluster_id )
    references rhn_sat_cluster( recid )
    on delete cascade;

create sequence rhn_host_probes_recid_seq;

--$Log$
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--
--
--
