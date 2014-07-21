update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = '89ad4e8795a43f54' or key_id = '636dea19a0a7badb';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '89ad4e8795a43f54', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '89ad4e8795a43f54'));

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '636dea19a0a7badb', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '636dea19a0a7badb'));
