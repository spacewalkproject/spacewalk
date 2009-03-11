--create schema
create schema rhn_package;
--update pg_setting
update pg_settings set setting = 'rhn_package,' || setting where name = 'search_path';
   

create or replace FUNCTION canonical_name(name_in IN VARCHAR, evr_in IN EVR_T,
                            arch_in IN VARCHAR(400))
    RETURNs VARCHAR as $$
    declare
        name_out     VARCHAR(256);
     
    BEGIN
        name_out := name_in || '-' ||evr_t_as_vre_simple(evr_in);
        
        IF arch_in IS NOT NULL
        THEN
            name_out := name_out || '-' || arch_in;
        END IF;

        RETURN name_out;
    END ;
    $$ language 'plpgsql';


create or replace FUNCTION channel_occupancy_string(package_id_in IN NUMERIC, separator_in VARCHAR) 
    RETURNS VARCHAR as $$
    declare
        list_out    VARCHAR(4000);
         channel_occupancy_cursor CURSOR (package_id_in  NUMeric) for
    SELECT C.id AS channel_id, C.name AS channel_name
      FROM rhnChannel C,
           rhnChannelPackage CP
     WHERE C.id = CP.channel_id
       AND CP.package_id = package_id_in
     ORDER BY C.name DESC;
     channel  record;
    separator_in varchar := ', ';
 
    BEGIN

        --FOR channel IN channel_occupancy_cursor(package_id_in)
       open channel_occupancy_cursor(package_id_in);
 LOOP
fetch channel_occupancy_cursor into channel;
exit when not found; 
       
            IF list_out IS NULL
            THEN
                list_out := channel.channel_name;
            ELSE
                list_out := channel.channel_name || separator_in || list_out;
            END IF;
        END LOOP;

        RETURN list_out;
    END ;
    $$ language 'plpgsql';

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_package')+1) ) where name = 'search_path';


