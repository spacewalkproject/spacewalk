-- oracle equivalent source sha1 5d0f21052fcc2d1b6ba7c5697989ae60fe0a73a0

CREATE OR REPLACE FUNCTION
lookup_xccdf_profile(identifier_in IN VARCHAR, title_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
    profile_id NUMERIC;
BEGIN
    SELECT id
        INTO profile_id
        FROM rhnXccdfProfile
        WHERE identifier = identifier_in
            AND title = title_in;

    IF NOT FOUND THEN
        INSERT INTO rhnXccdfProfile (id, identifier, title)
            VALUES (nextval('rhn_xccdf_profile_id_seq'),
                identifier_in, title_in)
            RETURNING id INTO profile_id;
    END IF;

    RETURN profile_id;
END;
$$ LANGUAGE PLPGSQL;
