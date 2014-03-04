update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = '2eb161fa246110c1';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '2eb161fa246110c1', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '2eb161fa246110c1'));
