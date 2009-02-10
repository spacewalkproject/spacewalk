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

--sat_cluster current prod row count = 112
create table 
rhn_sat_cluster
(
    recid                   numeric   (12) not null
        constraint rhn_satcl_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    target_type             varchar (10) default 'cluster' not null
        constraint rhn_satcl_target_type_ck check (target_type in ('cluster')),
    customer_id             numeric   (12) not null
				constraint rhn_satcl_cstmr_customer_id_fk 
    				references web_customer( id ),
    description             varchar (255) not null,
    last_update_user        varchar (40),
    last_update_date        date,
    physical_location_id    numeric   (12) not null
				constraint rhn_satcl_phslc_phys_loc_fk 
    				references rhn_physical_location( recid ),
    public_key              varchar (2000),
    vip                     varchar (15),
    deployed                char     (1)  default '0' not null
        constraint rhn_satcl_deployed_ck check (deployed in ('0','1')),
    pem_public_key          varchar (2000),
    pem_public_key_hash     varchar (20),
				constraint rhn_satcl_cmdtg_recid_tar_fk ( recid, target_type )
    				references rhn_command_target( recid, target_type )
    				on delete cascade
)

  ;

comment on table rhn_sat_cluster 
    is 'satcl  satellite cluster';

create index rhn_satcl_cid_idx
	on rhn_sat_cluster( customer_id )
--	tablespace [[4m_tbs]]
  ;

--
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
--
--
--
