alter table rhnOrgInfo drop column default_group_type;

alter table rhnOrgInfo add (
        staging_content VARCHAR2(1) NOT NULL 
                CONSTRAINT rhn_orginfo_staging_content_ck 
                CHECK (staging_content in ( 'Y' , 'N' ))
        );
