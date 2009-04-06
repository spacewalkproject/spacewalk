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

--sat_node current prod row count = 113
create table 
rhn_sat_node
(
	recid			numeric(12) not null
				constraint rhn_satnd_recid_pk primary key
--					using index tablespace [[2m_tbs]]
					,
        server_id               numeric
                                constraint rhn_satnd_sid_fk
	   			        references rhnServer(id),
	target_type		varchar(10) default 'node' not null
				constraint rhn_satnd_target_type_ck
					check (target_type in ('node')),
	last_update_user	varchar(40),
	last_update_date	date,
	mac_address		varchar(17) not null,
	max_concurrent_checks	numeric(4),
	sat_cluster_id		numeric(12) not null
				constraint rhn_satnd_satcl_sat_cl_id_fk
    				references rhn_sat_cluster( recid )
    				on delete cascade,
	ip			varchar(15),
	sched_log_level		numeric(4) default (0) not null,
	sput_log_level		numeric(4) default (0) not null,
	dq_log_level		numeric(4) default (0) not null,
	scout_shared_key	varchar(64) not null,
				constraint rhn_satnd_cmdtg_rid_tar_ty_fk foreign key ( recid, target_type )
    				references rhn_command_target( recid, target_type )
    				on delete cascade
)
  ;

comment on table rhn_sat_node is 'satnd  satellite node';

create index rhn_sat_node_scid_idx
on rhn_sat_node ( sat_cluster_id )
--   tablespace [[64k_tbs]]
--   nologging
  ;

create index rhn_sat_node_sid_idx
on rhn_sat_node ( server_id )
--   tablespace [[64k_tbs]]
--   nologging
  ;

--
--Revision 1.7  2004/10/12 15:05:45  rnorwood
--bugzilla: 135399 - updated .sql file and change file for server_id FK on rhn_sat_node.
--
--Revision 1.6  2004/09/28 21:17:00  pjones
--bugzilla: none -- commas.
--
--Revision 1.5  2004/09/28 16:54:46  pjones
--bugzilla: 133579 -- add scout shared key
--
--Revision 1.4  2004/09/27 21:40:37  pjones
--bugzilla: none -- reformat
--
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--
--
--
