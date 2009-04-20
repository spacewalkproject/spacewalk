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


CREATE OR REPLACE FUNCTION LOOKUP_PACKAGE_CAPABILITY_AUTONOMOUS(name_in IN VARCHAR, version_in IN VARCHAR)
RETURNs NUMERIC
AS
$$
DECLARE
      name_id         NUMERIC;
BEGIN
        IF version_in IS NULL THEN
                SELECT id
                  INTO name_id
                  FROM rhnPackageCapability
                 WHERE name = name_in
                   AND version IS NULL;
        ELSE
                SELECT id
                  INTO name_id
                  FROM rhnPackageCapability
                 WHERE name = name_in
                   AND version = version_in;
        END IF;

        IF NOT FOUND THEN
		INSERT INTO rhnPackageCapability (id, name, version) VALUES (nextval('rhn_pkg_capability_id_seq'), name_in, version_in);
		name_id := currval('rhn_pkg_capability_id_seq');
        END IF;
        
        RETURN name_id;
END;
$$
LANGUAGE PLPGSQL;



CREATE OR REPLACE FUNCTION
LOOKUP_PACKAGE_CAPABILITY(name_in IN VARCHAR,version_in IN VARCHAR)
RETURNS NUMERIC
AS $$
DECLARE
             ret_val         NUMERIC;
BEGIN

        select retcode into ret_val
        from dblink('dbname='||current_database(),
        'select LOOKUP_PACKAGE_CAPABILITY_AUTONOMOUS('||coalesce(name_in::varchar,'null')||','
        ||coalesce(version_in::varchar,'null')||')')
        as f(retcode numeric);

        RETURN ret_val;
END; $$ language plpgsql;
