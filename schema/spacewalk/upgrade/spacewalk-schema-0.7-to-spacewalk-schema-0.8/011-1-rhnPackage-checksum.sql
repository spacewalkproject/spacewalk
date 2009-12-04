alter table rhnPackage add checksum_id NUMBER
        CONSTRAINT rhn_package_chsum_fk
        REFERENCES rhnChecksum (id);
