--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--


CREATE OR REPLACE FUNCTION LOOKUP_TRANSACTION_PACKAGE_AUTONOMOUS(o_in IN VARCHAR, n_in IN VARCHAR,
    e_in IN VARCHAR, v_in IN VARCHAR, r_in IN VARCHAR, a_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
       o_id        NUMERIC;
        n_id        NUMERIC;
        e_id        NUMERIC;
        p_arch_id   NUMERIC;
        tp_id       NUMERIC;
BEGIN
        BEGIN
            SELECT id
              INTO o_id
              FROM rhnTransactionOperation
             WHERE label = o_in;
        IF NOT FOUND THEN
		PERFORM rhn_exception.raise_exception('invalid_transaction_operation');
	END IF;
                           
        END;

        SELECT LOOKUP_PACKAGE_NAME(n_in)
          INTO n_id;

        SELECT LOOKUP_EVR(e_in, v_in, r_in)
          INTO e_id;

        p_arch_id := NULL;
        IF a_in IS NOT NULL
        THEN
                SELECT LOOKUP_PACKAGE_ARCH(a_in)
                  INTO p_arch_id
                  FROM dual;
        END IF;

        SELECT id
          INTO tp_id
          FROM rhnTransactionPackage
         WHERE operation = o_id
           AND name_id = n_id
           AND evr_id = e_id
           AND (package_arch_id = p_arch_id OR (p_arch_id IS NULL AND package_arch_id IS NULL));
        

        IF NOT FOUND THEN
		INSERT INTO rhnTransactionPackage
                (id, operation, name_id, evr_id, package_arch_id) VALUES (nextval('rhn_transpack_id_seq'), o_id, n_id, e_id, p_arch_id);
                tp_id := currval('rhn_transpack_id_seq');
        END IF;

        RETURN tp_id;
END;
$$
LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION LOOKUP_TRANSACTION_PACKAGE(o_in IN VARCHAR, n_in IN VARCHAR,
    e_in IN VARCHAR, v_in IN VARCHAR, r_in IN VARCHAR, a_in IN VARCHAR)
RETURNS NUMERIC
AS $$
DECLARE
             ret_val         NUMERIC;
BEGIN

        select retcode into ret_val
        from dblink('dbname='||current_database(),
        'select LOOKUP_TRANSACTION_PACKAGE_AUTONOMOUS('||coalesce(name_in::varchar,'null')||','
        ||COALESCE(o_in::varchar,'null')||','
        ||COALESCE(n_invarchar,'null')||','
        ||COALESCE(e_in::varchar,'null')||','
        ||COALESCE(v_in::varchar,'null')||','
        ||COALESCE(r_in::varchar,'null')||','
        ||COALESCE(a_in::varchar,'null')||')')
        as f(retcode numeric);

        RETURN ret_val;
END;
$$ language plpgsql;


