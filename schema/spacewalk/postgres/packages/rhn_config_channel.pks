create schema rhn_config_channel;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_config_channel,' || setting where name = 'search_path';  

CREATE OR REPLACE FUNCTION get_user_chan_access(config_channel_id_in IN NUMERIC, user_id_in IN NUMERIC)
RETURNS NUMERIC as $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION get_user_revision_access(config_revision_id_in IN NUMERIC, user_id_in IN NUMERIC)
RETURNS NUMERIC
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION get_user_file_access(config_file_id_in IN NUMERIC, user_id_in IN NUMERIC)
RETURNS NUMERIC
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ language 'plpgsql';

CREATE OR REPLACE FUNCTION action_diff_revision_status(action_config_revision_id_in numeric)
RETURNS VARCHAR
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END; 
$$ LANGUAGE plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_config_channel')+1) ) where name = 'search_path';
