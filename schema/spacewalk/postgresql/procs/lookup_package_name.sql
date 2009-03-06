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
LOOKUP_PACKAGE_NAME_AUTONOMOUS(name_in IN VARCHAR, ignore_null in NUMERIC)
RETURNS NUMERIC
AS
$$
DECLARE
        name_id         NUMERIC;
BEGIN
        if ignore_null = 1 and name_in is null then
                return null;
        end if;

        SELECT id
          INTO name_id
          FROM rhnPackageName
         WHERE name = name_in;

         IF NOT FOUND THEN
		INSERT INTO rhnPackageName (id, name) VALUES (nextval('rhn_pkg_name_seq'), name_in);
		name_id := currval('rhn_pkg_name_seq');
         
         END IF;

        RETURN name_id;

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION LOOKUP_PACKAGE_NAME(name_in VARCHAR,ignore_null in NUMERIC)
RETURNS NUMERIC
AS
$$
DECLARE
	ret_val	NUMERIC;
BEGIN
	SELECT rectcode into ret_val from dblink('dbname='||current_database(),
	'SELECT LOOKUP_PACKAGE_NAME_AUTONOMOUS ('
	||COALESCE(name_in::varchar,'null')||','
	||COALESCE(0::numeric,'null')||')')
	as f(retcode numeric);

	return ret_val;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION LOOKUP_PACKAGE_NAME(name_in VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
	ret_val	NUMERIC;
BEGIN
	SELECT rectcode into ret_val from dblink('dbname='||current_database(),
        'SELECT LOOKUP_PACKAGE_NAME_AUTONOMOUS ('
        ||COALESCE(name_in::varchar,'null')||','
        ||COALESCE(0::numeric,'null')||')')
        as f(retcode numeric);

	return ret_val;
END;
$$ LANGUAGE PLPGSQL;


