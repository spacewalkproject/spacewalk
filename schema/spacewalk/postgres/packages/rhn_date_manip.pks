
create schema rhn_date_manip;

update pg_settings set setting = 'rhn_date_manip,' || setting where name = 'search_path';

create or replace function get_reporting_period_start()
returns date
as $$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return current_date;
end;
$$ language 'plpgsql';

create or replace function get_reporting_period_end()
returns date as
$$
begin
  raise exception 'Stub called, must be replace by .pkb';
  return current_date;
end;
$$ language 'plpgsql';

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_date_manip')+1) ) where name = 'search_path';
