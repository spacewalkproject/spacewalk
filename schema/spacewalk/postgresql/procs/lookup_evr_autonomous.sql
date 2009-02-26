CREATE OR REPLACE FUNCTION
LOOKUP_EVR_AUTONOMOUS(e_in IN VARCHAR, v_in IN VARCHAR, r_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
       evr_id          NUMERIC;
BEGIN
        SELECT id INTO evr_id
          FROM rhnPackageEvr
         WHERE ((epoch IS NULL and e_in IS NULL) OR (epoch = e_in))
           AND version = v_in AND release = r_in;
            

        IF NOT FOUND THEN
		INSERT INTO rhnPackageEvr (id, epoch, version, release, evr)
            VALUES (nextval('rhn_pkg_evr_seq'), e_in, v_in, r_in,EVR_T(e_in, v_in, r_in));

            evr_id := currval('rhn_pkg_evr_seq');
        END IF;

        RETURN evr_id;
END;
$$ LANGUAGE PLPGSQL;
