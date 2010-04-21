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

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '5326810137017186', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '219180cddb42a60e', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, 'b44269d04f2a6fd2', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, 'a8a447dce8562897', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '2802e89216ff0e46', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, 'a53d0bab443e1821', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '7049e44d025e513b', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '25dbef78a7048f8d', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '66ced3de1e5e0159', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '2e2bcdbcb38a8516', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, 'a84edae89c800aca', lookup_package_key_type('gpg'), lookup_package_provider('Suse'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '1dc5c758d22e77f2', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

-- Fedora 12
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '9d1cc34857bbccba', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(rhn_pkey_id_seq.nextval, '95423d4e430a1c35', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));

commit;

--
-- Revision 1.1  2008/07/02 23:42:28  jsherrill
-- Sequence; data to populate stuff
--

