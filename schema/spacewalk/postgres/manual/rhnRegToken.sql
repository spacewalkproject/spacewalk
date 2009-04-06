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
rhnRegToken
(
	id		numeric not null
			constraint rhn_reg_token_pk primary key,
	org_id		numeric not null
			constraint rhn_reg_token_oid_fk
				references web_customer(id)
				on delete cascade,
	user_id		numeric
			constraint rhn_reg_token_uid_fk
				references web_contact(id)
				on delete set null,
	server_id	numeric
			constraint rhn_reg_token_sid_fk
				references rhnServer(id),
	note		varchar(2048) not null,
	usage_limit     numeric default 0,
        disabled        numeric default 0 not null,
-- TODO: Should this be a boolean?
	deploy_configs	char(1) default('Y') not null
			constraint rhn_reg_token_deployconfs_ck
				check (deploy_configs in ('Y','N'))
)
;

create index rhn_reg_token_org_id_idx
	on rhnRegToken(org_id, id)
--	tablespace [[64k_tbs]]
--	nologging
;

create index rhn_reg_token_uid_idx
	on rhnRegToken ( user_id )
--	tablespace [[64k_tbs]]
--	nologging
;

create index rhn_reg_token_sid_idx
	on rhnRegToken( server_id )
--	tablespace [[8m_tbs]]
--	nologging
;

create sequence rhn_reg_token_seq;

