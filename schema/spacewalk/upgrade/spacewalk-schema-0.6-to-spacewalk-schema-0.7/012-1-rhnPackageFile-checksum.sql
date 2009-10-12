alter table rhnPackageFile add checksum_id NUMBER
        CONSTRAINT rhn_package_file_chsum_fk
        REFERENCES rhnChecksum (id);
