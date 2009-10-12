alter table rhnPackageSource add sigchecksum_id NUMBER
        CONSTRAINT rhn_pkgsrc_sigchsum_fk
        REFERENCES rhnChecksum (id);
alter table rhnPackageSource add checksum_id NUMBER
        CONSTRAINT rhn_pkgsrc_chsum_fk
        REFERENCES rhnChecksum (id);
