
ALTER table rhnChannelContentSource rename to rhnContentSource;

ALTER table rhnTaskQueue
add task_data_two NUMBER;


-- create new table for mapping channels and repos
CREATE TABLE rhnChannelContentSource
(
    source_id     NUMBER NOT NULL
                         CONSTRAINT rhn_ccs_src_id_fk
                             REFERENCES rhnContentSource (id)
                             ON DELETE CASCADE,
    channel_id    NUMBER NOT NULL
                         CONSTRAINT rhn_ccs_cid_fk
                             REFERENCES rhnChannel (id)
                             ON DELETE CASCADE,
    created          DATE
                         DEFAULT (sysdate) NOT NULL,
    modified         DATE
                         DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

-- add the contraints
ALTER TABLE rhnChannelContentSource
    ADD CONSTRAINT rhn_ccs_uq UNIQUE (source_id, channel_id)
    USING INDEX TABLESPACE [[4m_tbs]];

ALTER TABLE rhnContentSource
    ADD org_id number
        CONSTRAINT rhn_cs_org_fk
        REFERENCES WEB_CUSTOMER(id);

DECLARE
  -- grab any rows that need the channel to be migrated to new channel content mapping tbl
  CURSOR content is
    select cs.id, cs.channel_id, c.org_id
    from rhnContentSource cs, rhnChannel c
    where 1=1
    AND c.id = cs.channel_id
BEGIN
  FOR content_rec IN content
  LOOP
      INSERT INTO rhnChannelContentSource (source_id, channel_id)
             VALUES (content_rec.id, content_rec.channel_id);
      UPDATE rhnConentSource set org_id = content_rec.org_id
      WHERE 1=1
      AND channel_id = content_rec.channel_id;
  END LOOP;
  commit;
END;
/

-- we don't need the channel_id column anymore since mapping table will handle it
ALTER TABLE rhnContentSource DROP (channel_id);
