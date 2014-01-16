--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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

-- Red Hat
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '5326810137017186', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '219180cddb42a60e', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));

-- RHEL 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '199e2f91fd431d51', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));


-- Fedora
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'b44269d04f2a6fd2', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '1dc5c758d22e77f2', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

-- Fedora 12
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '9d1cc34857bbccba', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 13
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '7edc6ad6e8e40fde', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 14
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '421caddb97a1071f', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 15
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'b4ebf579069c8460', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 16
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '067f00b6a82ba4b7', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 17
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '50e94c991aca3465', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 18
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '0983129322b3b81a', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 19
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '07477e65fb4b18e6', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 20
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '2eb161fa246110c1', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));

-- CentOS
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'a8a447dce8562897', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '2802e89216ff0e46', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'a53d0bab443e1821', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '7049e44d025e513b', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));
-- CentOS 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '0946fca2c105b9de', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));


-- Scientific Linux
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '25dbef78a7048f8d', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux'));
-- Scientific Linux 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '915d75e09b1fd350', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'b0b4183f192a7d7d', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux'));


-- Oracle EL
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '66ced3de1e5e0159', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '2e2bcdbcb38a8516', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '72f97b74ec551f03', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.'));


-- Novell
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '2afe16421d061a62', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '14c28bc97e2e3b05', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '478a32e8a1912208', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '73d25d630dfb3188', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.'));

-- SUSE
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'a84edae89c800aca', lookup_package_key_type('gpg'), lookup_package_provider('SUSE'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'e3a5c360307e3d54', lookup_package_key_type('gpg'), lookup_package_provider('SUSE'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '6c74ce73b37b98a9', lookup_package_key_type('gpg'), lookup_package_provider('SUSE'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '8055f0400182b964', lookup_package_key_type('gpg'), lookup_package_provider('SUSE'));


-- Spacewalk
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '95423d4e430a1c35', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'ed635379b3892132', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '0e646f68863a853d', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));

-- EPEL 5
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '119cc036217521f6', lookup_package_key_type('gpg'), lookup_package_provider('EPEL'));
-- EPEL 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '3b49df2a0608b895', lookup_package_key_type('gpg'), lookup_package_provider('EPEL'));


commit;

