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

DELETE FROM rhnchannelerrata
      WHERE (channel_id, errata_id) in (SELECT ce.channel_id, ce.errata_id
                                          FROM rhnchannelerrata ce
                                          JOIN rhnchannel c ON c.id = ce.channel_id
                                          JOIN rhnerrata e ON e.id = ce.errata_id
                                         WHERE e.org_id <> c.org_id);

DELETE FROM rhnerratapackage
      WHERE (errata_id, package_id) in (SELECT pe.errata_id, pe.package_id
                                          FROM rhnerratapackage pe
                                          JOIN rhnpackage p ON p.id = pe.package_id
                                          JOIN rhnerrata e ON e.id = pe.errata_id
                                         WHERE e.org_id <> p.org_id);
