-- EPEL 7
update rhnPackageKey set provider_id = lookup_package_provider('EPEL')
 where key_id = '6a2faea2352c64e5';

insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '6a2faea2352c64e5', lookup_package_key_type('gpg'), lookup_package_provider('EPEL') from dual
     where 1 not in (select 1 from rhnPackageKey where key_id = '6a2faea2352c64e5'));
