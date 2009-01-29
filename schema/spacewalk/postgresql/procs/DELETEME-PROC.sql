CREATE OR REPLACE FUNCTION return_int(returnme INTEGER) RETURNS int AS $$
DECLARE
    myInt int;
    BEGIN
            myInt := returnme;
            RETURN myInt;
    END
$$ LANGUAGE 'plpgsql';
