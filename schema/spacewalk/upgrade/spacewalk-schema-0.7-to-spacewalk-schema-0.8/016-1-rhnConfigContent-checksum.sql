alter table rhnConfigContent add checksum_id NUMBER
        CONSTRAINT rhn_confcontent_chsum_fk
        REFERENCES rhnChecksum (id);
