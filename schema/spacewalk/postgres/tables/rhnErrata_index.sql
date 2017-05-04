-- oracle equivalent source sha1 aa0ee224ac3d5995e5677e0546ce364db4033546
--
-- Copyright (c) 2017 Red Hat, Inc.
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

CREATE UNIQUE INDEX rhn_errata_advname_uq
    ON rhnErrata (advisory_name)
 WHERE org_id IS NULL;

CREATE UNIQUE INDEX rhn_errata_advname_org_uq
    ON rhnErrata (advisory_name, org_id)
 WHERE org_id IS NOT NULL;

CREATE UNIQUE INDEX rhn_errata_adv_uq
    ON rhnErrata (advisory)
 WHERE org_id IS NULL;

CREATE UNIQUE INDEX rhn_errata_adv_org_uq
    ON rhnErrata (advisory, org_id)
 WHERE org_id IS NOT NULL;
