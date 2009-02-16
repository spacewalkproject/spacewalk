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

--check_probe current prod row count = 26713
create table 
rhn_check_probe
(
    probe_id        	numeric(12) not null
        		constraint rhn_chkpb_probe_id_pk primary key,
--            		using index tablespace [[4m_tbs]]
		            
    probe_type      	varchar(12) default 'check' not null
        		constraint chkpb_probe_type_ck 
            		check (probe_type='check'),

    host_id         	numeric   (12) not null
		    	constraint rhn_chkpb_host_id_fk  
    		    	references rhnServer( id ),
    sat_cluster_id  	numeric   (12) not null
		    	constraint rhn_chkpb_satcl_sat_cl_id_fk  
		        references rhn_sat_cluster( recid )
    			on delete cascade,
--			using tablespace [[4m_tbs]]
			constraint rhn_chkpb_pid_ptype_uq_idx unique (probe_id, probe_type),
			constraint rhn_chkpb_recid_probe_typ_fk foreign key (probe_id, probe_type)           
                        references rhn_probe( recid, probe_type )
                        on delete cascade
)
;

comment on table rhn_check_probe 
    is 'CHKPB  Service check probe definitions (monitoring)';

create index rhn_chkpb_host_id_idx 
    on rhn_check_probe ( host_id )
--    tablespace [[4m_tbs]]
  ;

create index rhn_chkpb_sat_cluster_id_idx
    on rhn_check_probe ( sat_cluster_id )
--    tablespace [[4m_tbs]]
  ;

--
--Revision 1.7  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.6  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/19 15:44:51  kja
--Adjustments from primary key audit.
--
--Revision 1.3  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--Revision 1.1  2004/04/08 22:52:31  kja
--Converting monitoring schema to rhn style -- a work in progress.
--
--
--
--
