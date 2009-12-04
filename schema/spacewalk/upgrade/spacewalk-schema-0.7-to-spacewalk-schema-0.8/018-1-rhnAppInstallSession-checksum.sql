alter table rhnAppInstallSession add checksum_id NUMBER
        CONSTRAINT rhn_appinst_session_chsum_fk
        REFERENCES rhnChecksum (id);
