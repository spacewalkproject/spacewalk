
update rhnPackageKey set provider_id = lookup_package_provider('Suse')
 where key_id = 'e3a5c360307e3d54';
update rhnPackageKey set provider_id = lookup_package_provider('Suse')
 where key_id = '6c74ce73b37b98a9';
update rhnPackageKey set provider_id = lookup_package_provider('Suse')
 where key_id = '8055f0400182b964';


insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'e3a5c360307e3d54', lookup_package_key_type('gpg'), lookup_package_provider('Suse') from dual
     where not exists (select 1 from rhnPackageKey where key_id = 'e3a5c360307e3d54'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '6c74ce73b37b98a9', lookup_package_key_type('gpg'), lookup_package_provider('Suse') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '6c74ce73b37b98a9'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '8055f0400182b964', lookup_package_key_type('gpg'), lookup_package_provider('Suse') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '8055f0400182b964'));


update rhnPackageProvider set name = 'SUSE' where name = 'Suse';

commit;
