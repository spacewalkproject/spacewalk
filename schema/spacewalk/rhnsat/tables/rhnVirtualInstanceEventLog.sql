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
rhnVirtualInstanceEventLog
(
	id			number
				constraint rhn_viel_id_nn not null
				constraint rhn_viel_id_pk primary key
					using index tablespace [[64k_tbs]],
	virtual_instance_id	number
				constraint rhn_viel_vii_fk
					references rhnVirtualInstance(id)
					on delete cascade,
	event_type		number
				constraint rhn_viel_et_nn not null
				constraint rhn_viel_et_fk
					references
					rhnVirtualInstanceEventType(id),
-- Either this:
	event_metadata		varchar2(4000),
-- Or these 10 (10, so far!  Yuck!) columns:
	old_state		number
				constraint rhn_viel_old_state_nn not null
				constraint rhn_viel_old_state_fk
					   references rhnVirtualInstanceState(id),
	new_state               number
				constraint rhn_viel_new_state_nn not null
				constraint rhn_viel_new_state_fk
					   references rhnVirtualInstanceState(id),
	old_memory_size_k	number,
	new_memory_size_k	number,
	old_vcpus		number,
	new_vcpus		number,
	old_host_system_id	number,
	new_host_system_id	number,
	old_host_system_name	varchar2(128),
	new_host_system_name	varchar2(128),
--
	local_timestamp		date
				constraint rhn_viel_lt_nn not null,
	created			date default (sysdate)
				constraint rhn_viel_created_nn not null,
	modified		date default (sysdate)
				constraint rhn_viel_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_viel_id_seq;

create index rhn_viel_vii_idx
	on rhnVirtualInstanceEventLog(virtual_instance_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;



--
