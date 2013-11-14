-- oracle equivalent source sha1 9f3cf822ce526d1396838ceaf5fb952d37704611

insert into rhnPackageEnhances (package_id, capability_id, sense)
  select s.package_id, s.capability_id, s.sense
    from rhnPackageSupplements s
   where (s.sense::bigint & 134217728) != 134217728;
-- 134217728 == (1 << 27) STRONG FLAG in RPM

delete from rhnPackageSupplements
 where (sense::bigint & 134217728) != 134217728;
