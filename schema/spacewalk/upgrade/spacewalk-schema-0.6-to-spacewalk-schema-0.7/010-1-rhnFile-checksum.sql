alter table rhnFile add checksum_id NUMBER
        CONSTRAINT rhn_file_chsum_fk
        REFERENCES rhnChecksum (id);
