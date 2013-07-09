CREATE TABLE web_contact_all
(
    id                 NUMBER
                           CONSTRAINT web_contact_all_pk PRIMARY KEY
                           USING INDEX TABLESPACE [[web_index_tablespace_2]],
    org_id             NUMBER NOT NULL
                           CONSTRAINT web_contact_all_org_fk
                               REFERENCES web_customer (id),
    login              VARCHAR2(64) NOT NULL
)
ENABLE ROW MOVEMENT;
