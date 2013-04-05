update rhnTimezone
   set display_name = 'Australia (Eastern Daylight)'
 where olson_name = 'Australia/Sydney';

insert into rhnTimezone (id, olson_name, display_name) (
    select sequence_nextval('rhn_timezone_id_seq'),
           'Australia/Brisbane',
           'Australia (Eastern Standard)'
      from dual
     where not exists (
           select 1
             from rhnTimezone
            where olson_name = 'Australia/Brisbane'
              and display_name = 'Australia (Eastern Standard)'
     )
);
