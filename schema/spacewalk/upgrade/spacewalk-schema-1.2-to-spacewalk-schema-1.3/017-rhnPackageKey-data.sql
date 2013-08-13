-- Fedora 13
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) (
       select sequence_nextval('rhn_pkey_id_seq'),
              '7edc6ad6e8e40fde',
              lookup_package_key_type('gpg'),
              lookup_package_provider('Fedora')
         from dual
        where not exists (
              select 1
                from rhnPackageKey
               where key_id = '7edc6ad6e8e40fde'
                 and key_type_id = lookup_package_key_type('gpg')
                 and provider_id = lookup_package_provider('Fedora')
        )
);

-- Fedora 14
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) (
       select sequence_nextval('rhn_pkey_id_seq'),
              '421caddb97a1071f',
              lookup_package_key_type('gpg'),
              lookup_package_provider('Fedora')
         from dual
        where not exists (
              select 1
                from rhnPackageKey
               where key_id = '421caddb97a1071f'
                 and key_type_id = lookup_package_key_type('gpg')
                 and provider_id = lookup_package_provider('Fedora')
        )
);
 
-- Spacewalk
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) (
       select sequence_nextval('rhn_pkey_id_seq'),
              'ed635379b3892132',
              lookup_package_key_type('gpg'),
              lookup_package_provider('Spacewalk')
         from dual
        where not exists (
              select 1
                from rhnPackageKey
               where key_id = 'ed635379b3892132'
                 and key_type_id = lookup_package_key_type('gpg')
                 and provider_id = lookup_package_provider('Spacewalk')
        )
);

-- RHEL 6
insert into rhnPackageKey (id, key_id, key_type_id, provider_id) (
       select sequence_nextval('rhn_pkey_id_seq'),
              '199e2f91fd431d51',
              lookup_package_key_type('gpg'),
              lookup_package_provider('Red Hat Inc.')
         from dual
        where not exists (
              select 1
                from rhnPackageKey
               where key_id = '199e2f91fd431d51'
                 and key_type_id = lookup_package_key_type('gpg')
                 and provider_id = lookup_package_provider('Red Hat Inc.')
        )
);
