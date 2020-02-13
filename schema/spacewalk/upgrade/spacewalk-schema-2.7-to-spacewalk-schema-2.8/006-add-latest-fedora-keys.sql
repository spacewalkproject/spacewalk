insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), 'FDB19C98', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = 'FDB19C98');

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), '64DAB85D', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = '64DAB85D');

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), 'F5282EE4', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = 'F5282EE4');

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), '9DB62FB1', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = '9DB62FB1');
