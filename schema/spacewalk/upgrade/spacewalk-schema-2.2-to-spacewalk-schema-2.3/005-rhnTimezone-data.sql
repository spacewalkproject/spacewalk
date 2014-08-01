insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'Asia/Seoul',
           'Korea'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'Asia/Seoul'
              and display_name = 'Korea'
     )
);
