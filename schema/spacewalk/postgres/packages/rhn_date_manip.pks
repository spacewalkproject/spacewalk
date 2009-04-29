
create schema rhn_date_manip;

update pg_settings set setting = 'rhn_date_manip,' || setting where name = 'search_path';

create or replace function get_reporting_period_start()
returns timestamptz
as $$
begin
  raise exception 'Stub called, must be replaced by .pkb';
end;
$$ language 'plpgsql';

create or replace function get_reporting_period_end()
returns timestamptz as
$$
begin
  raise exception 'Stub called, must be replaced by .pkb';
end;
$$ language 'plpgsql';

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_date_manip')+1) ) where name = 'search_path';
