-- created by Oraschemadoc Mon Aug 31 10:54:43 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM1"."RPM" AS
    FUNCTION vercmp(
        e1 VARCHAR2, v1 VARCHAR2, r1 VARCHAR2,
        e2 VARCHAR2, v2 VARCHAR2, r2 VARCHAR2)
    RETURN NUMBER
        DETERMINISTIC
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmp, WNDS, RNDS);

    FUNCTION vercmpCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpCounter, WNDS, RNDS);

    FUNCTION vercmpResetCounter
    return NUMBER
        PARALLEL_ENABLE;
    PRAGMA RESTRICT_REFERENCES(vercmpResetCounter, WNDS, RNDS);

END rpm;
CREATE OR REPLACE PACKAGE BODY "MIM1"."RPM" AS
    vercmp_counter NUMBER := 0;

    FUNCTION isdigit(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END isdigit;


    FUNCTION isalpha(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or
            ascii(ch) between ascii('A') and ascii('Z')
        then
            return TRUE;
        end if;
        return FALSE;
    END isalpha;


    FUNCTION isalphanum(ch CHAR)
    RETURN BOOLEAN
    deterministic
    IS
    BEGIN
        if ascii(ch) between ascii('a') and ascii('z') or
            ascii(ch) between ascii('A') and ascii('Z') or
            ascii(ch) between ascii('0') and ascii('9')
        then
            return TRUE;
        end if;
        return FALSE;
    END isalphanum;


    FUNCTION rpmstrcmp (string1 IN VARCHAR2, string2 IN VARCHAR2)
    RETURN NUMBER
    deterministic
    IS
        digits CHAR(10) := '0123456789';
        lc_alpha CHAR(27) := 'abcdefghijklmnopqrstuvwxyz';
        uc_alpha CHAR(27) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        alpha CHAR(54) := lc_alpha || uc_alpha;
        str1 VARCHAR2(32767) := string1;
        str2 VARCHAR2(32767) := string2;
        one VARCHAR2(32767);
        two VARCHAR2(32767);
        isnum BOOLEAN;
    BEGIN
        if str1 is NULL or str2 is NULL
        then
            raise VALUE_ERROR;
        end if;
        -- easy comparison to see if versions are identical
        if str1 = str2
        then
            return 0;
        end if;
        -- loop through each version segment of str1 and str2 and compare them
        one := str1;
        two := str2;

        <<segment_loop>>
        while one is not null and two is not null
        loop
            declare
                segm1 VARCHAR2(32767);
                segm2 VARCHAR2(32767);
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
                --DBMS_OUTPUT.PUT_LINE('new params: ' || one || ',' || two);

                str1 := one;
                str2 := two;

                /* grab first completely alpha or completely numeric segment */
                /* leave one and two pointing to the start of the alpha or numeric */
                /* segment and walk str1 and str2 to end of segment */

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

                --DBMS_OUTPUT.PUT_LINE('Len: ' || length(str1) || ',' || length(str2));
                -- Oracle trats the length of an empty string as null
                if str1 is not null
                then segm1 := substr(one, 1, length(one) - length(str1));
                else segm1 := one;
                end if;

                if str2 is not null
                then segm2 := substr(two, 1, length(two) - length(str2));
                else segm2 := two;
                end if;

                --DBMS_OUTPUT.PUT_LINE('Segments: ' || segm1 || ',' || segm2);
                --DBMS_OUTPUT.PUT_LINE('Rest: ' || str1 || ',' || str2);
                /* take care of the case where the two version segments are */
                /* different types: one numeric and one alpha */
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
                    /* this used to be done by converting the digit segments */
                    /* to ints using atoi() - it's changed because long */
                    /* digit segments can overflow an int - this should fix that. */

                    /* throw away any leading zeros - it's a number, right? */
                    segm1 := ltrim(segm1, '0');
                    segm2 := ltrim(segm2, '0');

                    /* whichever number has more digits wins */
                    -- length of empty string is null
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

                /* strcmp will return which one is greater - even if the two */
                /* segments are alpha or if they are numeric.  don't return  */
                /* if they are equal because there might be more segments to */
                /* compare */

                if segm1 < segm2 then return -1; end if;
                if segm1 > segm2 then return 1; end if;

                one := str1;
                two := str2;
            end;
        end loop segment_loop;
        /* this catches the case where all numeric and alpha segments have */
        /* compared identically but the segment sepparating characters were */
        /* different */
        if one is null and two is null then return 0; end if;

        /* whichever version still has characters left over wins */
        if one is null then return -1; end if;
        return 1;
    END rpmstrcmp;


    FUNCTION vercmp(
        e1 VARCHAR2, v1 VARCHAR2, r1 VARCHAR2,
        e2 VARCHAR2, v2 VARCHAR2, r2 VARCHAR2)
    RETURN NUMBER
    IS
        rc NUMBER;
    BEGIN
        DECLARE
          ep1 NUMBER;
          ep2 NUMBER;
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

    END vercmp;

    FUNCTION vercmpCounter
    RETURN NUMBER
    IS
    BEGIN
        return vercmp_counter;
    END vercmpCounter;

    FUNCTION vercmpResetCounter
    RETURN NUMBER
    IS
        result NUMBER;
    BEGIN
        result := vercmp_counter;
        vercmp_counter := 0;
        return result;
    END vercmpResetCounter;
END rpm;
 
/
