-- Fedora 30
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'CFC659B9', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 31
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '3C3359C4', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));


-- CentOS 8
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '05b555b38483c65d', lookup_package_key_type('gpg'), lookup_package_provider('CentOS'));

-- Spacewalk 2.10
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '3ae9b50430912c76', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '770ce53ebc2e6843', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));
-- Spacewalk nightly
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'e481344adba67ea3', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'd4b984391b9881e5', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));

-- EPEL 8
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '21ea45ab2f86d6a1', lookup_package_key_type('gpg'), lookup_package_provider('EPEL'));
 
