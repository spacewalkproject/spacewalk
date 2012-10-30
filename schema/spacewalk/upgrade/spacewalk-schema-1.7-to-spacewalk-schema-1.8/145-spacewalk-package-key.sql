
update rhnPackageKey set provider_id = lookup_package_provider('Spacewalk')
 where key_id = '0e646f68863a853d';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '0e646f68863a853d', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '0e646f68863a853d'));

commit;
