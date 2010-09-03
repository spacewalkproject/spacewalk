UPDATE rhnTimezone SET display_name = 'United States (Central Daylight Time)'
    WHERE olson_name = 'America/Chicago';

INSERT INTO rhnTimezone (id, olson_name, display_name)
  VALUES (rhn_timezone_id_seq.nextval,
          'America/Regina', 'United States(Central Standard Time)');


