alter table rhnKSTreeFile add checksum_id NUMBER
        CONSTRAINT rhn_kstreefile_chsum_fk
        REFERENCES rhnChecksum (id);
