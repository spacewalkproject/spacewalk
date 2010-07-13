alter table web_customer add (
        staging_content_enabled VARCHAR2(1) NOT NULL 
                CONSTRAINT web_customer_staging_content_ck 
                CHECK (staging_content in ( 'Y' , 'N' ))
        );
