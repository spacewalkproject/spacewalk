-- oracle equivalent source sha1 c4e4389b599d4186dfe59d3f5432233d8faf0a49

CREATE OR REPLACE FUNCTION
lookup_xccdf_ident(system_in IN VARCHAR, identifier_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
    xccdf_ident_id NUMERIC;
    ident_sys_id NUMERIC;
BEGIN
    SELECT id
        INTO ident_sys_id
        FROM rhnXccdfIdentsystem
        WHERE system = system_in;
    IF NOT FOUND THEN
        INSERT INTO rhnXccdfIdentsystem (id, system)
            VALUES (nextval('rhn_xccdf_identsytem_id_seq'), system_in)
            RETURNING id INTO ident_sys_id;
    END IF;

    SELECT id
        INTO xccdf_ident_id
        FROM rhnXccdfIdent
        WHERE identsystem_id = ident_sys_id
            AND identifier = identifier_in;
    IF NOT FOUND THEN
        INSERT INTO rhnXccdfIdent (id, identsystem_id, identifier)
            VALUES (nextval('rhn_xccdf_ident_id_seq'), ident_sys_id, identifier_in)
            RETURNING id INTO xccdf_ident_id;
    END IF;
    RETURN xccdf_ident_id;
END;
$$ LANGUAGE PLPGSQL;
