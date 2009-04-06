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
LOOKUP_CONFIG_FILENAME_AUTONOMOUS(name_in IN VARCHAR)
RETURNS NUMERIC
AS $$
DECLARE
        
        name_id         NUMERIC;
BEGIN
        SELECT id
          INTO name_id
          FROM rhnConfigFileName
         WHERE path = name_in;

	IF NOT FOUND THEN
		INSERT INTO rhnConfigFileName (id, path) VALUES (nextval('rhn_cfname_id_seq'), name_in);
                name_id := currval('rhn_cfname_id_seq');
        END IF;

END; $$
LANGUAGE plpgsql;
