CREATE TABLE web_contact_all
(
    id                 NUMBER
                           CONSTRAINT web_contact_all_pk PRIMARY KEY
                           USING INDEX TABLESPACE [[web_index_tablespace_2]],
    org_id             NUMBER,
    login              VARCHAR2(64) NOT NULL
)
ENABLE ROW MOVEMENT;
