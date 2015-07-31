-- oracle equivalent source sha1 31bc60e73b873355d9251bbea814bf57fd3a4c87
-- create schema rpm;

--update pg_setting
update pg_settings set setting = 'rpm,' || setting where name = 'search_path';

create or replace function isdigit(ch CHAR)
    RETURNS BOOLEAN as $$
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
    RETURNS INTEGER as $$
    declare
        str1 VARCHAR := string1;
        str2 VARCHAR := string2;
        digits VARCHAR(10) := '0123456789';
        lc_alpha VARCHAR(27) := 'abcdefghijklmnopqrstuvwxyz';
        uc_alpha VARCHAR(27) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        alpha VARCHAR(54) := lc_alpha || uc_alpha;
        one VARCHAR;
        two VARCHAR;
        isnum BOOLEAN;
    BEGIN
        if str1 is NULL or str2 is NULL
        then
            RAISE EXCEPTION 'VALUE_ERROR.';
        end if;
      
        if str1 = str2
        then
            return 0;
        end if;
        one := str1;
        two := str2;

        <<segment_loop>>
        while one <> '' and two <> ''
        loop
            declare
                segm1 VARCHAR;
                segm2 VARCHAR;
            begin
                --DBMS_OUTPUT.PUT_LINE('Params: ' || one || ',' || two);
                -- Throw out all non-alphanum characters
                while one <> '' and not rpm.isalphanum(one)
                loop
                    one := substr(one, 2);
                end loop;
                while two <> '' and not rpm.isalphanum(two)
                loop
                    two := substr(two, 2);
                end loop;
                str1 := one;
                str2 := two;
                if str1 <> '' and rpm.isdigit(str1)
                then
                    str1 := ltrim(str1, digits);
                    str2 := ltrim(str2, digits);
                    isnum := true;
                else
                    str1 := ltrim(str1, alpha);
                    str2 := ltrim(str2, alpha);
                    isnum := false;
                end if;
                if str1 <> ''
                then segm1 := substr(one, 1, length(one) - length(str1));
                else segm1 := one;
                end if;
                    
                if str2 <> ''
                then segm2 := substr(two, 1, length(two) - length(str2));
                else segm2 := two;
                end if;
                if segm1 = '' then return -1; end if; /* arbitrary */
                if segm2 = '' then
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

                    if segm1 = '' and segm2 <> ''
                    then
                        return -1;
                    end if;
                    if segm1 <> '' and segm2 = ''
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
     
        if one = '' and two = '' then return 0; end if;
        if one = '' then return -1; end if;
        return 1;
    END ;
$$ language 'plpgsql';



   create or replace FUNCTION vercmp(
        e1 VARCHAR, v1 VARCHAR, r1 VARCHAR, 
        e2 VARCHAR, v2 VARCHAR, r2 VARCHAR)
    RETURNS INTEGER as $$
    declare
        rc INTEGER;
          ep1 INTEGER;
          ep2 INTEGER;
          BEGIN
            if e1 is null or e1 = '' then
              ep1 := 0;
            else
              ep1 := e1::integer;
            end if;
            if e2 is null or e2 = '' then
              ep2 := 0;
            else
              ep2 := e2::integer;
            end if;
            -- Epochs are non-null; compare them
            if ep1 < ep2 then return -1; end if;
            if ep1 > ep2 then return 1; end if;
            rc := rpm.rpmstrcmp(v1, v2);
            if rc != 0 then return rc; end if;
           return rpm.rpmstrcmp(r1, r2);
         END;
         $$ language 'plpgsql';

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rpm')+1) ) where name = 'search_path';

