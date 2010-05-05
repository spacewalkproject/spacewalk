
ALTER table rhnChannelContentSource rename to rhnContentSource;

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

DECLARE
  -- grab any rows that need the channel to be migrated to new channel content mapping tbl
  CURSOR content is
    select id, channel_id
    from rhnContentSource
    where 1=1
BEGIN
  FOR content_rec IN content
  LOOP
      INSERT INTO rhnChannelContentSource (source_id, channel_id)
             VALUES (content_rec.id, content_rec.channel_id);
  END LOOP;
  commit;
END;
/

-- we don't need the channel_id column anymore since mapping table will handle it
ALTER TABLE rhnContentSource DROP (channel_id);
