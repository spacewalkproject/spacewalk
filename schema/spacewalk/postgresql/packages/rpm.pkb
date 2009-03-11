--create schema
create schema rpm;
--update pg_setting
update pg_settings set setting = 'rpm,' || setting where name = 'search_path';

create or replace function isdigit(ch CHAR)
    RETURNS BOOLEAN as $$
    declare 
    vercmp_counter NUMERIC := 0;
    BEGIN
        if ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END ;
$$ language 'plpgsql';


    
    create or replace FUNCTION isalpha(ch CHAR)
    RETURNS BOOLEAN as $$
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or 
            ascii(ch) between ascii('A') and ascii('Z')
        then
            return TRUE;
        end if;
        return FALSE;
    END;
$$ language 'plpgsql';


    create or replace FUNCTION isalphanum(ch CHAR)
    RETURNS BOOLEAN as $$ 
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or 
            ascii(ch) between ascii('A') and ascii('Z') or
            ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END;
    $$ language 'plpgsql';


    create or replace FUNCTION rpmstrcmp (string1 IN VARCHAR, string2 IN VARCHAR)
    RETURNS NUMERIC as $$
    declare
        digits CHAR(10) := '0123456789';
        lc_alpha CHAR(27) := 'abcdefghijklmnopqrstuvwxyz';
        uc_alpha CHAR(27) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        alpha CHAR(54) := lc_alpha || uc_alpha;
        str1 VARCHAR(32767) := string1;
        str2 VARCHAR(32767) := string2;
        one VARCHAR(32767);
        two VARCHAR(32767);
        isnum BOOLEAN;
    BEGIN
        if str1 is NULL or str2 is NULL
        then
            --raise VALUE_ERROR;
        RAISE EXCEPTION 'VALUE_ERROR.';
             null;
        end if;
      
        if str1 = str2
        then
            return 0;
        end if;
        one := str1;
        two := str2;

        <<segment_loop>>
        while one is not null and two is not null
        loop
            declare
                segm1 VARCHAR(32767);
                segm2 VARCHAR(32767);
            begin
                --DBMS_OUTPUT.PUT_LINE('Params: ' || one || ',' || two);
                -- Throw out all non-alphanum characters
                while one is not null and not isalphanum(one)
                loop
                    one := substr(one, 2);
                end loop;
                while two is not null and not isalphanum(two)
                loop
                    two := substr(two, 2);
                end loop;
                str1 := one;
                str2 := two;
                if str1 is not null and isdigit(str1)
                then
                    str1 := ltrim(str1, digits);
                    str2 := ltrim(str2, digits);
                    isnum := true;
                else
                    str1 := ltrim(str1, alpha);
                    str2 := ltrim(str2, alpha);
                    isnum := false;
                end if;
                if str1 is not null
                then segm1 := substr(one, 1, length(one) - length(str1));
                else segm1 := one;
                end if;
                    
                if str2 is not null
                then segm2 := substr(two, 1, length(two) - length(str2));
                else segm2 := two;
                end if;
                if segm1 is null then return -1; end if; /* arbitrary */
                if segm2 is null then
                                        if isnum then
                                                return 1;
                                        else
                                                return -1;
                                        end if;
                                end if;
                if isnum
                then
                   
                    segm1 := ltrim(segm1, '0');
                    segm2 := ltrim(segm2, '0');

                    if segm1 is null and segm2 is not null
                    then
                        return -1;
                    end if;
                    if segm1 is not null and segm2 is null
                    then
                        return 1;
                    end if;
                    if length(segm1) > length(segm2) then return 1; end if;
                    if length(segm2) > length(segm1) then return -1; end if;
                end if;
                  if segm1 < segm2 then return -1; end if;
                if segm1 > segm2 then return 1; end if;
               one := str1;
                two := str2;
            end;
        end loop segment_loop;
     
        if one is null then return -1; end if;
        return 1;
    END ;
$$ language 'plpgsql';



   create or replace FUNCTION vercmp(
        e1 VARCHAR, v1 VARCHAR, r1 VARCHAR, 
        e2 VARCHAR, v2 VARCHAR, r2 VARCHAR)
    RETURNS NUMERIC as $$
    declare
        rc NUMERIC;
     vercmp_counter NUMeric := 0;
          ep1 NUMERIC;
          ep2 NUMERIC;
          BEGIN
            vercmp_counter := vercmp_counter + 1;
            if e1 is null then
              ep1 := 0;
            else
              ep1 := TO_NUMBER(e1);
            end if;
            if e2 is null then
              ep2 := 0;
            else
              ep2 := TO_NUMBER(e2);
            end if;
            -- Epochs are non-null; compare them
            if ep1 < ep2 then return -1; end if;
            if ep1 > ep2 then return 1; end if;
            rc := rpmstrcmp(v1, v2);
            if rc != 0 then return rc; end if;
           return rpmstrcmp(r1, r2);
         END;
         $$ language 'plpgsql';



    CREATE OR REPLACE FUNCTION vercmpCounter()
    RETURNS NUMERIC AS $$
    declare
    vercmp_counter numeric:=0;
    BEGIN
        return vercmp_counter;
    END ;
    $$ language 'plpgsql';

    CREATE OR REPLACE FUNCTION vercmpResetCounter()
    RETURNS NUMeric AS $$
    DECLARE
        result NUMERIC;
        vercmp_counter numeric :=0;
    BEGIN
        result := vercmp_counter;
        vercmp_counter := 0;
        return result;
    END;
$$ language 'plpgsql';
-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rpm')+1) ) where name = 'search_path';

