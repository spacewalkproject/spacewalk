DROP INDEX rhn_cs_uq;


BEGIN
FOR i IN
    (SELECT cs.id, keep.min_id
        FROM rhnContentSource cs,
        (SELECT org_id, type_id, source_url, min(id) min_id
            FROM rhnContentSource
            GROUP BY org_id, type_id, source_url
            HAVING count(*) > 1) keep
        WHERE cs.org_id = keep.org_id
        AND cs.type_id = keep.type_id
        AND cs.source_url = keep.source_url
        AND cs.id > keep.min_id)
LOOP
-- remap duplicate repo referencies in rhnChannelContentSource to the lowest one
    DELETE FROM rhnChannelContentSource
        WHERE source_id = i.id
        AND EXISTS
            (SELECT 1 FROM rhnChannelContentSource
                WHERE source_id = i.min_id);
    UPDATE rhnChannelContentSource
        SET source_id = i.min_id
        WHERE source_id = i.id;
-- delete repo duplicates
    DELETE FROM rhnContentSource
        WHERE id = i.id;
END LOOP;
END;
/

-- rename label duplicates
UPDATE rhnContentSource cs
    SET label = cs.label || cs.id
    WHERE cs.id IN
    (SELECT id FROM rhnContentSource cs,
        (SELECT org_id, label, min(id) min_id
            FROM rhnContentSource
            GROUP BY org_id, label
            HAVING count(*) > 1) keep
    WHERE cs.org_id = keep.org_id
    AND cs.label = keep.label
    AND cs.id > keep.min_id);


CREATE UNIQUE INDEX rhn_cs_label_uq
    ON rhnContentSource(org_id, label)
    tablespace [[64k_tbs]];
CREATE UNIQUE INDEX rhn_cs_repo_uq
    ON rhnContentSource(org_id, type_id, source_url)
    tablespace [[64k_tbs]];
