--
-- Add in a column for selinux context
--

ALTER TABLE rhnConfigInfo
  ADD selinux_ctx VARCHAR(64);

DROP INDEX RHN_CONFINFO_UGF_UQ;

CREATE UNIQUE INDEX rhn_confinfo_ugf_uq
    ON rhnConfigInfo( username, groupname, filemode, selinux_ctx )
    tablespace [[4m_tbs]]
  ;

CREATE OR REPLACE FUNCTION
lookup_config_info (
    username_in     IN VARCHAR2,
    groupname_in    IN VARCHAR2,
    filemode_in     IN VARCHAR2,
    selinux_ctx_in  IN VARCHAR2
) RETURN NUMBER
DETERMINISTIC
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_id    NUMBER;
    CURSOR lookup_cursor IS
        SELECT id
          FROM rhnConfigInfo
         WHERE 1=1
           AND username = username_in
           AND groupname = groupname_in
           AND filemode = filemode_in
           AND nvl(selinux_ctx, ' ') = nvl(selinux_ctx_in, ' ');
BEGIN
    FOR r IN lookup_cursor LOOP
        RETURN r.id;
    END LOOP;
    -- If we got here, we don't have the id
    SELECT rhn_confinfo_id_seq.nextval
      INTO v_id
      FROM dual;
    INSERT INTO rhnConfigInfo (id, username, groupname, filemode, selinux_ctx)
    VALUES (v_id, username_in, groupname_in, filemode_in, selinux_ctx_in);
    COMMIT;
    RETURN v_id;
END lookup_config_info;
/
show errors
