update rhnPackageKey set provider_id = lookup_package_provider('Oracle Inc.')
 where key_id = '72f97b74ec551f03';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '72f97b74ec551f03', lookup_package_key_type('gpg'), lookup_package_provider('Oracle Inc.') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '72f97b74ec551f03'));
