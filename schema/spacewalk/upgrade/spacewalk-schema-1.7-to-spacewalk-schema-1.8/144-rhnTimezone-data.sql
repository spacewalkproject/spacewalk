insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'Africa/Johannesburg',
           'South Africa (Johannesburg)'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'Africa/Johannesburg'
              and display_name = 'South Africa (Johannesburg)'
     )
);
