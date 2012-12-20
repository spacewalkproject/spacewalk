update rhnTimezone
   set display_name = 'Australia (Eastern Daylight)'
 where olson_name = 'Australia/Sydney';

insert into rhnTimezone
  (id, olson_name, display_name)
values
  (sequence_nextval('rhn_timezone_id_seq'),
   'Australia/Brisbane', 'Australia (Eastern Standard)');
