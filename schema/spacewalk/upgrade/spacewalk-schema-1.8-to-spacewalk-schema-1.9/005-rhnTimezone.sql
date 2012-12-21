update rhnTimezone
   set olson_name = 'Australia/Perth'
 where olson_name = 'Asia/Hong_Kong' and display_name = 'Australia (Western)';
