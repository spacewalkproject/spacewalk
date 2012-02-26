
CREATE OR REPLACE FUNCTION
lookup_xccdf_ident(system_in IN VARCHAR2, identifier_in IN VARCHAR2)
RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    xccdf_ident_id NUMBER;
    ident_sys_id NUMBER;
BEGIN
    BEGIN
        SELECT id
            INTO ident_sys_id
            FROM rhnXccdfIdentsystem
            WHERE system = system_in;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO rhnXccdfIdentsystem (id, system)
                VALUES (rhn_xccdf_identsytem_id_seq.nextval, system_in)
                RETURNING id INTO ident_sys_id;
    END;

    SELECT id
        INTO xccdf_ident_id
        FROM rhnXccdfIdent
        WHERE identsystem_id = ident_sys_id
            AND identifier = identifier_in;
    RETURN xccdf_ident_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO rhnXccdfIdent (id, identsystem_id, identifier)
            VALUES (rhn_xccdf_ident_id_seq.nextval, ident_sys_id, identifier_in)
            RETURNING id INTO xccdf_ident_id;
        COMMIT;
    RETURN xccdf_ident_id;
END lookup_xccdf_ident;
/
SHOW ERRORS
