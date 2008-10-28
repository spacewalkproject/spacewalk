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
rhnChannelTrust
(
	channel_id	number
			constraint rhn_channel_trust_cid_nn not null
			constraint rhn_channel_trust_cid_fk
				references rhnChannel(id)
                                on delete cascade,
	org_trust_id	number
			constraint rhn_channel_trust_otid_nn not null
			constraint rhn_channel_trust_otid_fk
				references web_customer(id)
                                on delete cascade,
        created         date default (sysdate)
                        constraint rhn_channel_trust_created_nn not null,
        modified        date default (sysdate)
                        constraint rhn_channel_trust_modified_nn not null
)
	storage( pctincrease 1 freelists 16)
	enable row movement
	initrans 32;

create unique index rhn_channel_trust_cid_uq
	on rhnChannelTrust(channel_id,org_trust_id)
	tablespace [[2m_tbs]]
	storage( pctincrease 1 freelists 16)
	initrans 32;

create index rhn_channel_trust_org_trust
	on rhnChannelTrust(org_trust_id)
	tablespace [[2m_tbs]]
	storage( pctincrease 1 freelists 16)
	initrans 32;
