--
-- Double the copyright from
-- 64 -> 128 to resolve rhnpush 
-- for centos packages
--

ALTER TABLE rhnPackage
MODIFY
    COPYRIGHT VARCHAR2(128);
