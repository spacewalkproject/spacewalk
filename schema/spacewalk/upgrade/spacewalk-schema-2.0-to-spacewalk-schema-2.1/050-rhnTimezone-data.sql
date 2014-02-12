insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'Asia/Riyadh',
           'Saudi Arabia'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'Asia/Riyadh'
              and display_name = 'Saudi Arabia'
     )
);
