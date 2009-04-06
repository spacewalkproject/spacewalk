
--create schema rhn_date_manip;

update pg_settings set setting = 'rhn_date_manip,' || setting where name = 'search_path';

create or replace function get_reporting_period_start()
        returns date as $$
                declare
                months_ago      numeric;
                weeks_ago       numeric;
                target_date     date;
                day_number      numeric;
                periods_ago     numeric;
        begin
                months_ago := periods_ago/2;
                weeks_ago := mod(periods_ago,2);
               -- target_date := trunc(add_months(current_timestamp::date,-months_ago)-(7*weeks_ago));
               target_date := trunc((current_timestamp + (-months_ago||' months')::interval)-((7*weeks_ago)||' days')::interval);
                day_number := to_char(target_date,'DD')::numeric;
                -- squish the date to the 1st or the 16th
               if day_number > 16 then
                        target_date := target_date - ((day_number||' day')::interval - (16||'day')::interval);
                else
                        target_date := target_date - ((day_number||' day')::interval - (1||'day')::interval);
                end if;
                return target_date;
        end ;
      $$ language 'plpgsql';



       create or replace function get_reporting_period_end()
        returns date as $$
             declare
                months_ago      numeric;
                weeks_ago       numeric;
                target_date     date;
                day_number      numeric;
                periods_ago     numeric;
        begin
                months_ago := periods_ago/2;
                weeks_ago := mod(periods_ago,2);

                --target_date := trunc(add_months(current_timestamp,-months_ago)-(7*weeks_ago));
                target_date := trunc((current_timestamp + (-months_ago||' months')::interval)-((7*weeks_ago)||' days')::interval);
                day_number := to_char(target_date,'DD')::numeric;
                -- squish the date to the 1st or the 16th
                if day_number > 16 then
                        target_date := last_day(target_date);
                else
                        target_date := target_date + ((-day_number||' day')::interval + (15||' day')::interval) + ((1||' day')::interval-(1/86400||' day')::interval);
                end if;
                return target_date;
        end ;
  $$   language 'plpgsql';



-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_date_manip')+1) ) where name = 'search_path';

