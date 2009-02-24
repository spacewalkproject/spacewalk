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
	instance_id		numeric not null
				constraint rhn_vii_viid_fk
				references rhnVirtualInstance(id)
				on delete cascade
				constraint rhn_vii_viid_uq unique,
-- 				using tablespace [[64K_tbs]]
	instance_type		numeric not null
				constraint rhn_vii_it_fk
				references rhnVirtualInstanceType(id),
	memory_size_k		numeric,
	vcpus			numeric,
	state			numeric not null
				constraint rhn_vii_state_fk
				references rhnVirtualInstanceState(id),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
)
;

create sequence rhn_vii_id_seq;

;
	

--
