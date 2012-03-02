--
-- Copyright (c) 2012 Red Hat, Inc.
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

-- Fedora 16
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '067f00b6a82ba4b7', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 17
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '50e94c991aca3465', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 18
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '0983129322b3b81a', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

