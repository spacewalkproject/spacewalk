insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'America/Santiago',
           'Chile (Continental)'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'America/Santiago'
              and display_name = 'Chile (Continental)'
     )
);

insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'Pacific/Easter',
           'Chile (Easter Island)'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'Pacific/Easter'
              and display_name = 'Chile (Easter Island)'
     )
);
