insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), '73bde98381b46521', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = '73bde98381b46521');

insert into rhnPackageKey (id, key_id, key_type_id, provider_id) select sequence_nextval('rhn_pkey_id_seq'), 'b8635eeb030d5aed', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual where not exists (select 1 from rhnPackageKey where key_id = 'b8635eeb030d5aed');

