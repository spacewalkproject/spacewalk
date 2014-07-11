update rhnPackageKey set provider_id = lookup_package_provider('CentOS')
 where key_id = '24c6a8a7f4a80eb5';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '24c6a8a7f4a80eb5', lookup_package_key_type('gpg'), lookup_package_provider('CentOS') from dual
     where not exists (select 1 from rhnPackageKey where key_id = '24c6a8a7f4a80eb5'));
