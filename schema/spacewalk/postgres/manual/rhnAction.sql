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
rhnAction
(
	id		numeric not null
			constraint rhn_action_pk primary key
--				using index tablespace [[4m_tbs]]
				,
	org_id		numeric not null
			constraint rhn_action_oid_fk
				references web_customer(id)
				on delete cascade,
	action_type	numeric not null
			constraint rhn_action_at_fk
				references rhnActionType(id),
	name            varchar(128),
	scheduler	numeric
			constraint rhn_action_scheduler_fk
				references web_contact(id)
				on delete set null,
	earliest_action	timestamp not null,
	version		numeric default 0 not null,
	archived        numeric default 0 not null
			constraint rhn_action_archived_ck
				check (archived in (0, 1)),
        prerequisite    numeric
                        constraint rhn_action_prereq_fk
                                references rhnAction(id) on delete cascade,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
);

-- this is common with the stuff used by rhnServerHistory now
create sequence rhn_event_id_seq;

create index rhn_action_oid_idx
	on rhnAction(org_id)
--	tablespace [[8m_tbs]]
;

create index rhn_action_scheduler_idx
	on rhnAction(scheduler)
--	tablespace [[8m_tbs]]
;

create index rhn_action_prereq_id_idx
        on rhnAction(prerequisite, id)
--	tablespace [[8m_tbs]]
;

