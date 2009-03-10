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
	id			numeric not null
				constraint rhn_viel_id_pk primary key,
--				using index tablespace [[64k_tbs]],
	virtual_instance_id	numeric
				constraint rhn_viel_vii_fk
				references rhnVirtualInstance(id)
				on delete cascade,
	event_type		numeric not null
				constraint rhn_viel_et_fk
				references rhnVirtualInstanceEventType(id),
-- Either this:
	event_metadata		varchar(4000),
-- Or these 10 (10, so far!  Yuck!) columns:
	old_state		numeric not null
				constraint rhn_viel_old_state_fk
			        references rhnVirtualInstanceState(id),
	new_state               numeric not null
				constraint rhn_viel_new_state_fk
				references rhnVirtualInstanceState(id),
	old_memory_size_k	numeric,
	new_memory_size_k	numeric,
	old_vcpus		numeric,
	new_vcpus		numeric,
	old_host_system_id	numeric,
	new_host_system_id	numeric,
	old_host_system_name	varchar(128),
	new_host_system_name	varchar(128),
--
	local_timestamp		timestamp not null,
	created			date default(current_timestamp) not null,
	modified		date default(current_timestamp) not null
)
;

create sequence rhn_viel_id_seq;

create index rhn_viel_vii_idx
	on rhnVirtualInstanceEventLog(virtual_instance_id)
-- 	tablespace [[64k_tbs]]
  ;



--
