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
rhnServer
(
        id              numeric not null
                        constraint rhn_server_id_pk primary key
--	                        using index tablespace [[4m_tbs]]
				,
        org_id          numeric not null
                        constraint rhn_server_oid_fk
                                references web_customer(id)
				on delete cascade,
        digital_server_id varchar(64) not null
			constraint rhn_server_dsid_uq unique
--			using index tablespace [[8m_tbs]]
				,
	server_arch_id	numeric not null
			constraint rhn_server_said_fk
				references rhnServerArch(id),
        os              varchar(64) not null,
        release         varchar(64) not null,
        name            varchar(128),
        description     varchar(256),
        info            varchar(128),
        secret          varchar(32) not null,
	creator_id	numeric
			constraint rhn_server_creator_fk
				references web_contact(id)
				on delete set null,
	auto_deliver	char(1) default 'N' not null
			constraint rhn_server_deliver_ck
				check (auto_deliver in ('Y', 'N')),
	auto_update     char(1) default 'N' not null
			constraint rhn_server_update_ck
				check (auto_update in ('Y', 'N')),
	running_kernel  varchar(64),
        last_boot       numeric default 0 not null,
	provision_state_id numeric
			constraint rhn_server_psid_fk
				references rhnProvisionState(id),
	channels_changed timestamp,
	cobbler_id      varchar(64),
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null
);

create sequence rhn_server_id_seq start with 1000010000;

create index rhn_server_oid_id_idx
	on rhnServer(org_id,id)
--        tablespace [[4m_tbs]]
;

create index rhn_server_created_id_idx
	on rhnServer(created,id)
--        tablespace [[4m_tbs]]
;

-- this keeps delete_user from being _too_ slow
create index rhn_server_creator_idx
	on rhnServer(creator_id)
--	tablespace [[2m_tbs]]
;

