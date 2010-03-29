-- Spacewalk
merge into rhnPackageProvider p
     using (select 'Spacewalk' name from dual) s
        on (p.name = s.name)
      WHEN NOT MATCHED THEN INSERT (id, name)
                            VALUES (rhn_package_provider_id_seq.nextval, s.name);
