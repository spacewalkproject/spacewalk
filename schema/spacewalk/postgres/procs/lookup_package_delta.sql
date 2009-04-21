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

CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_DELTA_AUTONOMOUS(n_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
       name_id         NUMERIC;
BEGIN
        SELECT id INTO name_id
          FROM rhnPackageDelta
         WHERE label = n_in;

        RETURN name_id;

	IF NOT FOUND THEN
		INSERT INTO rhnPackageDelta (id, label) VALUES (nextval('rhn_packagedelta_id_seq'), n_in);
		name_id := currval('rhn_packagedelta_id_seq');
	END IF;

        RETURN name_id;
END;
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_DELTA(n_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
	ret_val NUMERIC;
BEGIN
	SELECT retcode into ret_val from dblink('dbname='||current_database(),
	'SELECT LOOKUP_PACKAGE_DELTA('
	||COALESCE(n_in::varchar,'null')||')')
	as f(retcode numeric);
	
	return ret_val;

END;
$$
LANGUAGE PLPGSQL;



