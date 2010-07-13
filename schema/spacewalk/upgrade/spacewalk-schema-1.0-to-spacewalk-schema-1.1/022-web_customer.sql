alter table web_customer add
        staging_content_enabled CHAR(1)
                    DEFAULT ('N') NOT NULL
                CONSTRAINT web_customer_stage_content_chk
                CHECK (staging_content_enabled in ( 'Y' , 'N' ));
