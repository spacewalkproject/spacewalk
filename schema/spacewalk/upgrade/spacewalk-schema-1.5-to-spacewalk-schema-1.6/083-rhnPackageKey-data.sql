-- Fedora 15
update rhnPackageKey set provider_id = lookup_package_provider('Fedora')
 where key_id = 'b4ebf579069c8460';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'b4ebf579069c8460', lookup_package_key_type('gpg'), lookup_package_provider('Fedora') from dual
      where 1 not in (select 1 from rhnPackageKey where key_id = 'b4ebf579069c8460'));

-- CentOS 6
update rhnPackageKey set provider_id = lookup_package_provider('CentOS')
 where key_id = '0946fca2c105b9de';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '0946fca2c105b9de', lookup_package_key_type('gpg'), lookup_package_provider('CentOS') from dual
    where 1 not in (select 1 from rhnPackageKey where key_id = '0946fca2c105b9de'));

-- Scientific Linux 6
update rhnPackageKey set provider_id = lookup_package_provider('Scientific Linux')
 where key_id = '915d75e09b1fd350';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '915d75e09b1fd350', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux') from dual
    where 1 not in (select 1 from rhnPackageKey where key_id = '915d75e09b1fd350'));
update rhnPackageKey set provider_id = lookup_package_provider('Scientific Linux')
 where key_id = 'b0b4183f192a7d7d';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), 'b0b4183f192a7d7d', lookup_package_key_type('gpg'), lookup_package_provider('Scientific Linux') from dual
    where 1 not in (select 1 from rhnPackageKey where key_id = 'b0b4183f192a7d7d'));

-- EPEL 5
update rhnPackageKey set provider_id = lookup_package_provider('EPEL')
 where key_id = '119cc036217521f6';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '119cc036217521f6', lookup_package_key_type('gpg'), lookup_package_provider('EPEL') from dual
    where 1 not in (select 1 from rhnPackageKey where key_id = '119cc036217521f6'));
-- EPEL 6
update rhnPackageKey set provider_id = lookup_package_provider('EPEL')
 where key_id = '3b49df2a0608b895';
insert into rhnPackageKey (id, key_id, key_type_id, provider_id)
    (select sequence_nextval('rhn_pkey_id_seq'), '3b49df2a0608b895', lookup_package_key_type('gpg'), lookup_package_provider('EPEL') from dual
    where 1 not in (select 1 from rhnPackageKey where key_id = '3b49df2a0608b895'));

commit;
