-- Fedora 12
merge into rhnpackagekey k
     using (select '9d1cc34857bbccba' key_id,
                   lookup_package_key_type('gpg') key_type_id,
                   lookup_package_provider('Fedora') provider_id
              from dual) s
        on (k.key_id = s.key_id)
      WHEN MATCHED THEN UPDATE SET k.key_type_id = s.key_type_id,
                                   k.provider_id = s.provider_id
      WHEN NOT MATCHED THEN INSERT (id, key_id, key_type_id, provider_id)
                            VALUES (rhn_pkey_id_seq.nextval, s.key_id, s.key_type_id, s.provider_id);

-- Spacewalk
merge into rhnpackagekey k
     using (select '95423d4e430a1c35' key_id,
                   lookup_package_key_type('gpg') key_type_id,
                   lookup_package_provider('Spacewalk') provider_id
              from dual) s
        on (k.key_id = s.key_id)
      WHEN MATCHED THEN UPDATE SET k.key_type_id = s.key_type_id,
                                   k.provider_id = s.provider_id
      WHEN NOT MATCHED THEN INSERT (id, key_id, key_type_id, provider_id)
                            VALUES (rhn_pkey_id_seq.nextval, s.key_id, s.key_type_id, s.provider_id);
