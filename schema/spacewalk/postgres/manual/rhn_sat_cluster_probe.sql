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

--sat_cluster_probe current prod row count = 0

create table 
rhn_sat_cluster_probe
(
    probe_id        numeric   (12) not null
        constraint rhn_sclpb_probe_id_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    probe_type      varchar (12) default 'satcluster' not null
        constraint rhn_sclpb_probe_type_ck check (probe_type='satcluster'),
    sat_cluster_id  numeric   (12) not null
			constraint rhn_sclpb_satcl_sat_cl_id_fk
    			references rhn_sat_cluster( recid )
    			on delete cascade,
			constraint rhn_sclpb_prb_recid_prb_typ_fk foreign key ( probe_id, probe_type )
    			references rhn_probe( recid, probe_type )
    			on delete cascade
)
  ;

comment on table rhn_sat_cluster_probe 
    is 'sclpb  satellite cluster probe definitions';

create index rhn_sclpb_sat_cluster_id_idx 
    on rhn_sat_cluster_probe ( sat_cluster_id ) 
--    tablespace [[2m_tbs]]
  ;

create index rhn_sclpb_pid_ptype_idx
    on rhn_sat_cluster_probe ( probe_id, probe_type )
--    tablespace [[2m_tbs]]
  ;


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
