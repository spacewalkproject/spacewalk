create schema rhn_channel_config;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_channel_config,' || setting where name = 'search_path';  

CREATE OR REPLACE FUNCTION action_diff_revision_status(action_config_revision_id_in numeric)
RETURNS VARCHAR(255)
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replace by .pkb';
  RETURN NULL;
END; 
$$ LANGUAGE plpgsql;

Create or replace FUNCTION get_user_chan_access(config_channel_id_in IN NUMERIC, user_id_in IN NUMERIC)
RETURNS NUMERIC as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replace by .pkb';
  RETURN 0;
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION get_user_revision_access(config_revision_id_in IN NUMERIC, user_id_in IN NUMERIC)
RETURNS NUMERIC
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replace by .pkb';
  RETURN 0;
END;
$$ language 'plpgsql';


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_config_channel')+1) ) where name = 'search_path';
