UPDATE rhnTimezone SET display_name = 'New Zealand (Wallis)'
    WHERE olson_name = 'Pacific/Wallis';

INSERT INTO rhnTimezone (id, olson_name, display_name)
  VALUES (rhn_timezone_id_seq.nextval,
          'Pacific/Auckland', 'New Zealand (Auckland)');
