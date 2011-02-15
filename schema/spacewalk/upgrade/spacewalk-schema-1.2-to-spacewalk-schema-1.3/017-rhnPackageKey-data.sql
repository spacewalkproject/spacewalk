-- Fedora 13
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '7edc6ad6e8e40fde', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
-- Fedora 14
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '421caddb97a1071f', lookup_package_key_type('gpg'), lookup_package_provider('Fedora'));
 
-- Spacewalk
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), 'ed635379b3892132', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk'));

-- RHEL 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) values
(sequence_nextval('rhn_pkey_id_seq'), '199e2f91fd431d51', lookup_package_key_type('gpg'), lookup_package_provider('Red Hat Inc.'));

