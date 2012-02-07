-- oracle equivalent source sha1 d5871e1909bf519b76964b26867a24a05cf1feba

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_config_channel,' || setting where name = 'search_path';  

CREATE OR REPLACE FUNCTION action_diff_revision_status(action_config_revision_id_in numeric)
RETURNS VARCHAR
        -- result_is_null obviously wants NVL2, but stupid 8.1.7.3.0 doesn't
        -- have that.  Or case.  So we're using union, instead.
   AS $$
   DECLARE
   failure_reason  VARCHAR(4000);
   result_is_null  numeric;
   result_exists  numeric;
BEGIN
   select extant,is_null,reason
   into   result_exists,result_is_null,failure_reason
   from(SELECT ACRR.ACTION_CONFIG_REVISION_ID AS EXTANT,1 AS IS_NULL, -- NVL2(ACRR.result, 0, 1),
                       CFF.NAME AS REASON
      FROM RHNACTIONCONFIGREVISION ACR LEFT OUTER JOIN RHNACTIONCONFIGREVISIONRESULT ACRR ON ACR.ID = ACRR.ACTION_CONFIG_REVISION_ID  LEFT OUTER JOIN RHNCONFIGFILEFAILURE CFF ON ACR.FAILURE_ID = CFF.ID 
      WHERE ACR.ID = action_config_revision_id_in AND ACRR.RESULT is null
      union all
      SELECT ACRR.ACTION_CONFIG_REVISION_ID AS EXTANT,0 AS IS_NULL, -- NVL2(ACRR.result, 0, 1),
                       CFF.NAME AS REASON
      FROM RHNACTIONCONFIGREVISION ACR LEFT OUTER JOIN RHNACTIONCONFIGREVISIONRESULT ACRR ON ACR.ID = ACRR.ACTION_CONFIG_REVISION_ID  LEFT OUTER JOIN RHNCONFIGFILEFAILURE CFF ON ACR.FAILURE_ID = CFF.ID 
      WHERE ACR.ID = action_config_revision_id_in AND ACRR.RESULT is not null) AS SWT_TABAL;
   IF failure_reason IS NOT NULL
   THEN
      RETURN failure_reason;
   END IF;

   IF result_exists IS NOT NULL
   THEN
      IF result_is_null = 1
      THEN
         RETURN 'No differences';
      END IF;
      RETURN 'Differences exist';
   END IF;

   RETURN NULL;
END; 
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_user_chan_access(config_channel_id_in IN NUMERIC, user_id_in IN NUMERIC)
    RETURNS NUMERIC as $$
    Declare
        server_id NUMERIC;
        org_matches NUMERIC;
        global_channel VARCHAR(30);
        any_visible_servers_subscribed NUMERIC;
    BEGIN

          SELECT 1 INTO org_matches
            FROM rhnConfigChannel CC,
                 web_contact WC
           WHERE WC.id = user_id_in
             AND CC.id = config_channel_id_in
             AND WC.org_id = CC.org_id;

          IF NOT FOUND THEN
            RETURN 0;
          END IF;

        global_channel := 'unknown';
        SELECT CCT.label INTO global_channel
          FROM rhnConfigChannel CC,
               rhnConfigChannelType CCT
         WHERE CC.id = config_channel_id_in
           AND CCT.id = CC.confchan_type_id;

        IF (rhn_user.check_role_implied(user_id_in, 'config_admin') = 1) AND (global_channel = 'normal')
        THEN
            RETURN 1;
        END IF;

          SELECT 1 INTO any_visible_servers_subscribed
            FROM DUAL
           WHERE EXISTS (
             SELECT SCC.server_id
               FROM rhnServerConfigChannel SCC,
                    rhnUserServerPermsDupes USPD
              WHERE USPD.user_id = user_id_in
                AND USPD.server_id = SCC.server_id
                AND SCC.config_channel_id = config_channel_id_in
           );

          IF NOT FOUND 
            THEN RETURN 0;
          END IF;

        RETURN any_visible_servers_subscribed;

    END ;
   $$ language 'plpgsql';

CREATE OR REPLACE FUNCTION get_user_revision_access(config_revision_id_in IN NUMERIC, user_id_in IN NUMERIC)
    RETURNS NUMERIC AS $$
    DECLARE
        config_channel_id NUMERIC;
     BEGIN

        SELECT CF.config_channel_id INTO config_channel_id
          FROM rhnConfigFile CF,
               rhnConfigRevision CR
         WHERE CF.id = CR.config_file_id
           AND CR.id = config_revision_id_in;

          if not found then
           RETURN 0;
          end if;

        RETURN rhn_config_channel.get_user_chan_access(config_channel_id, user_id_in);
    END;
    $$ language 'plpgsql';


    CREATE OR REPLACE FUNCTION get_user_file_access(config_file_id_in IN NUMERIC, user_id_in IN NUMERIC)
    RETURNS NUMERIC as $$
    declare
        config_channel_id NUMERIC;
    BEGIN

        SELECT CF.config_channel_id INTO config_channel_id
          FROM rhnConfigFile CF
         WHERE CF.id = config_file_id_in;

        IF NOT FOUND THEN
          RETURN 0;
        END IF;

        RETURN rhn_config_channel.get_user_chan_access(config_channel_id, user_id_in);
    END ;
    $$ language 'plpgsql';


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_config_channel')+1) ) where name = 'search_path';
