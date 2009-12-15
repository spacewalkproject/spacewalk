alter table rhnErrataFile add checksum_id NUMBER
        CONSTRAINT rhn_erratafile_chsum_fk
        REFERENCES rhnChecksum (id);
