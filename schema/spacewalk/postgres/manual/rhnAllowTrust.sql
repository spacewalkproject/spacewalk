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
-- $Id$
--

create table
rhnAllowTrust
(
	org_id		numeric  not null
			constraint rhn_allow_trust_oid_fk
				references web_customer(id)
                                on delete cascade,
			-- TODO: Should channel_flag be a boolean?
        channel_flag    char(1) default('N') not null
                        constraint rhn_allow_trust_channelflg_ck
                                check (channel_flag in ('N','Y')),
			-- TODO: Should migration_flag be a boolean?
        migration_flag  char(1) default('N') not null
                        constraint rhn_allow_trust_migrflg_ck
                                check (migration_flag in ('N','Y')),
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null
)
;
