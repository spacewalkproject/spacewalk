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
	org_id		number
			constraint rhn_allow_trust_oid_nn not null
			constraint rhn_allow_trust_oid_fk
				references web_customer(id)
                                on delete cascade,
        channel_flag    char(1) default('N')
                        constraint rhn_allow_trust_channelflg_nn not null
                        constraint rhn_allow_trust_channelflg_ck
                                check (channel_flag in ('N','Y')),
        migration_flag  char(1) default('N')
                        constraint rhn_allow_trust_migrflg_nn not null
                        constraint rhn_allow_trust_migrflg_ck
                                check (migration_flag in ('N','Y')),
        created         date default (sysdate)
                        constraint rhn_allow_trust_created_nn not null,
        modified        date default (sysdate)
                        constraint rhn_allow_trust_modified_nn not null
)
	storage( pctincrease 1 freelists 16)
	enable row movement
	initrans 32;
