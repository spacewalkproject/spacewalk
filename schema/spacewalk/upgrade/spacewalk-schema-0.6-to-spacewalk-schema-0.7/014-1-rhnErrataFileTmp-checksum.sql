alter table rhnErrataFileTmp add checksum_id NUMBER
        CONSTRAINT rhn_erratafiletmp_chsum_fk
        REFERENCES rhnChecksum (id);
