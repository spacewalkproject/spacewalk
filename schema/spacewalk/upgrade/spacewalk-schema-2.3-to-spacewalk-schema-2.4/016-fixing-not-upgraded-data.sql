-- Inserting into rhnPackageKey
update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = '11adc0948e1431d5';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '11adc0948e1431d5', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '11adc0948e1431d5'));

update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = 'd8d1fa8ca29cb19c';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'd8d1fa8ca29cb19c', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = 'd8d1fa8ca29cb19c'));

update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = 'dbeae2e4efe550f5';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'dbeae2e4efe550f5', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = 'dbeae2e4efe550f5'));

-- Inserting into rhnPackageUpgradeArchCompat
insert into rhnPackageUpgradeArchCompat (package_arch_id, package_upgrade_arch_id, created, modified) select
LOOKUP_PACKAGE_ARCH('ppc64le'), LOOKUP_PACKAGE_ARCH('ppc64le'), current_timestamp, current_timestamp from dual
where not exists (select 1 from rhnPackageUpgradeArchCompat where package_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le') and package_upgrade_arch_id = LOOKUP_PACKAGE_ARCH('ppc64le'));
