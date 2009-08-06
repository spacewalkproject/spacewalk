--
-- Double the package name from
-- 128 -> 256 to resolve customer issue with custom
-- package names.
--

ALTER TABLE rhnSourceRpm
MODIFY
    name VARCHAR2(256);

ALTER TABLE rhnPackageName
MODIFY
    name VARCHAR2(256);
