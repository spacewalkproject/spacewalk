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
rhnServerArch
(
	id		numeric
			constraint rhn_sarch_id_pk primary key,
	label		varchar(64) not null
			constraint rhn_sarch_label_uq unique,
	name		varchar(64) not null,
	arch_type_id	numeric not null
			constraint rhn_sarch_atid_fk
				references rhnArchType(id),
	created		timestamp default(current_timestamp) not null,
	modified	timestamp default(current_timestamp) not null
);

create sequence rhn_server_arch_id_seq start with 1000;

-- these must be in this order.
create index rhn_sarch_id_l_n_idx
	on rhnServerArch(id,label,name)
--	tablespace [[2m_tbs]]
  ;

-- these too.
create index rhn_sarch_l_id_n_idx
	on rhnServerArch(label,id,name)
--	tablespace [[2m_tbs]]
  ;

