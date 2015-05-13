update rhnPackageKey set provider_id = lookup_package_provider('Spacewalk')
 where key_id = '41605346066e5810';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '41605346066e5810', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '41605346066e5810'));

update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = '32474cf834ec9cba';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '32474cf834ec9cba', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '32474cf834ec9cba'));

update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = 'b4bb871c873529b8';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'b4bb871c873529b8', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
     where not exists (select 1 from rhnPackageKey where key_id = 'b4bb871c873529b8'));

update rhnPackageKey set provider_id = lookup_package_provider('Spacewalk')
 where key_id = 'dcc981cdb8002de1';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'dcc981cdb8002de1', lookup_package_key_type('gpg'), lookup_package_provider('Spacewalk') from dual
     where not exists (select 1 from rhnPackageKey where key_id = 'dcc981cdb8002de1'));
