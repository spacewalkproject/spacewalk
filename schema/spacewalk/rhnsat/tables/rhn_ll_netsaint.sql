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

--ll_netsaint current prod row count = 6
create table 
rhn_ll_netsaint
(
    netsaint_id number
        constraint rhn_llnet_netsaint_id_nn not null,
    city        varchar2 (255)
)
    enable row movement
  ;

comment on table rhn_ll_netsaint 
    is 'llnet  scout records';

alter table rhn_ll_netsaint
    add constraint rhn_llnts_sat_cluster_idfk
    foreign key ( netsaint_id )
    references rhn_sat_cluster( recid );

create index rhn_ll_ntsnts_nsid_idx
on rhn_ll_netsaint ( netsaint_id )
   tablespace [[64k_tbs]]
   nologging
  ;

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
