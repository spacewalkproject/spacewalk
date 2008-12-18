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


create table
rhnVirtualInstanceInfo
(
	name                    varchar(128),
	instance_id		number
				constraint rhn_vii_viid_nn not null
				constraint rhn_vii_viid_fk
					references rhnVirtualInstance(id)
					on delete cascade,
	instance_type		number
				constraint rhn_vii_it_nn not null
				constraint rhn_vii_it_fk
					references rhnVirtualInstanceType(id),
	memory_size_k		number,
	vcpus			number,
	state			number
				constraint rhn_vii_state_nn not null
				constraint rhn_vii_state_fk
					   references rhnVirtualInstanceState(id),
	created			date default (sysdate)
				constraint rhn_vii_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_vii_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_vii_id_seq;

create unique index rhn_vii_viid_uq
	on rhnVirtualInstanceInfo(instance_id)
	tablespace [[64k_tbs]]
  ;
	

--
