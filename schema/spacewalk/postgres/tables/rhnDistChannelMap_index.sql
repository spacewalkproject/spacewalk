-- oracle equivalent source sha1 ebaf5952b9989dfb12fd3f4488888756ca2d232d
--
-- Copyright (c) 2014 Red Hat, Inc.
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

create unique index rhn_dcm_rel_caid_oid_uq_idx
    on rhnDistChannelMap (release, channel_arch_id, org_id)
 where org_id is not null;

create unique index rhn_dcm_rel_caid_uq_idx
    on rhnDistChannelMap (release, channel_arch_id)
 where org_id is null;

