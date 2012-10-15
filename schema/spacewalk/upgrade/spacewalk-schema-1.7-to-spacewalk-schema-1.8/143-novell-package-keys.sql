
insert into rhnPackageProvider (id, name) values
(sequence_nextval('rhn_package_provider_id_seq'), 'Novell Inc.' );

update rhnPackageKey set provider_id = lookup_package_provider('Novell Inc.')
 where key_id = '2afe16421d061a62';
update rhnPackageKey set provider_id = lookup_package_provider('Novell Inc.')
 where key_id = '14c28bc97e2e3b05';
update rhnPackageKey set provider_id = lookup_package_provider('Novell Inc.')
 where key_id = '478a32e8a1912208';
update rhnPackageKey set provider_id = lookup_package_provider('Novell Inc.')
 where key_id = '73d25d630dfb3188';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '2afe16421d061a62', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '2afe16421d061a62'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '14c28bc97e2e3b05', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '14c28bc97e2e3b05'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '478a32e8a1912208', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '478a32e8a1912208'));
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '73d25d630dfb3188', lookup_package_key_type('gpg'), lookup_package_provider('Novell Inc.') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '73d25d630dfb3188'));


commit;
