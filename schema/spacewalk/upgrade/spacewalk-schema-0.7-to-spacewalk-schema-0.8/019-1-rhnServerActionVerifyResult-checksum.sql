alter table rhnServerActionVerifyResult
        rename column md5_differs to checksum_differs;
alter table rhnServerActionVerifyResult
        drop constraint rhn_sactionvr_md5_ck;
alter table rhnServerActionVerifyResult
        add constraint rhn_sactionvr_chsum_ck
        CHECK (checksum_differs in ( 'Y' , 'N' , '?' ));
