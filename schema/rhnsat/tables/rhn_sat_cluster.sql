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

--sat_cluster current prod row count = 112
create table 
rhn_sat_cluster
(
    recid                   number   (12)
        constraint rhn_satcl_recid_nn not null
        constraint rhn_satcl_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    target_type             varchar2 (10) default 'cluster'
        constraint rhn_satcl_target_type_nn not null
        constraint rhn_satcl_target_type_ck check (target_type in ('cluster')),
    customer_id             number   (12)
        constraint rhn_satcl_cust_id_nn not null,
    description             varchar2 (255)
        constraint rhn_satcl_desc_nn not null,
    last_update_user        varchar2 (40),
    last_update_date        date,
    physical_location_id    number   (12)
        constraint rhn_satcl_location_id_nn not null,
    public_key              varchar2 (2000),
    vip                     varchar2 (15),
    deployed                char     (1)  default '0'
        constraint rhn_satcl_deployed_nn not null
        constraint rhn_satcl_deployed_ck check (deployed in ('0','1')),
    pem_public_key          varchar2 (2000),
    pem_public_key_hash     varchar2 (20)
)
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_sat_cluster 
    is 'satcl  satellite cluster';

alter table rhn_sat_cluster
    add constraint rhn_satcl_cmdtg_recid_tar_fk
    foreign key ( recid, target_type )
    references rhn_command_target( recid, target_type )
    on delete cascade;

create index rhn_satcl_cid_idx
	on rhn_sat_cluster( customer_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhn_sat_cluster
    add constraint rhn_satcl_cstmr_customer_id_fk
    foreign key ( customer_id )
    references web_customer( id );

alter table rhn_sat_cluster
    add constraint rhn_satcl_phslc_phys_loc_fk
    foreign key ( physical_location_id )
    references rhn_physical_location( recid );

--$Log$
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.2  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--$Id$
--
--
