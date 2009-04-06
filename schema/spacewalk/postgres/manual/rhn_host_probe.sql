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
    probe_id        numeric   (12) not null
        constraint rhn_hstpb_probe_id_pk primary key
--            using index tablespace [[4m_tbs]]
            ,
    probe_type      varchar (12) default 'host' not null
        constraint rhn_hstpb_probe_type_ck check ( probe_type='host' ),
    host_id         numeric   (12) not null
			constraint rhn_hstpb_host_id_fk 
    			references rhnServer( id ),
    sat_cluster_id  numeric   (12) not null
			constraint rhn_hstpb_satcl_id_fk 
    			references rhn_sat_cluster( recid )
    			on delete cascade,
			constraint rhn_hstpb_pbid_ptype_idx unique ( probe_id, probe_type )
--    			tablespace [[4m_tbs]]
)  
  ;

comment on table rhn_host_probe 
    is 'hstpb  host probe definitions';

create index rhn_hstpb_host_id_idx 
    on rhn_host_probe ( host_id )
--    tablespace [[4m_tbs]]
  ;

create index rhn_hstpb_sat_cluster_id_idx 
    on rhn_host_probe ( sat_cluster_id )
--    tablespace [[4m_tbs]]
  ;

alter table rhn_host_probe
    add constraint rhn_hstpb_probe_probe_id_fk
    foreign key ( probe_id, probe_type )
    references rhn_probe( recid, probe_type )
    on delete cascade;

create sequence rhn_host_probes_recid_seq;

--
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
