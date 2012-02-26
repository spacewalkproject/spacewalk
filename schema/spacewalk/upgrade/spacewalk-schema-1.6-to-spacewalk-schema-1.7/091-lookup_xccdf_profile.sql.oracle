
CREATE OR REPLACE FUNCTION
lookup_xccdf_profile(identifier_in IN VARCHAR2, title_in IN VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    profile_id NUMBER;
BEGIN
    SELECT id
        INTO profile_id
        FROM rhnXccdfProfile
        WHERE identifier = identifier_in
            AND title = title_in;
    RETURN profile_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO rhnXccdfProfile (id, identifier, title)
            VALUES (rhn_xccdf_profile_id_seq.nextval,
                identifier_in, title_in)
            RETURNING id INTO profile_id;
        COMMIT;
    RETURN profile_id;
END lookup_xccdf_profile;
/
SHOW ERRORS
