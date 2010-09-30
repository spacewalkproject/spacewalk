-- oracle equivalent source sha1 df5951ee3fa3819c099453015dadcef459d90d5e
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/lookup_source_name.sql
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
LOOKUP_SOURCE_NAME(name_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
        source_id       NUMERIC;
BEGIN
        select  id into source_id
        from    rhnSourceRPM
        where   name = name_in;

	IF NOT FOUND THEN
		insert into rhnSourceRPM(id, name) values (nextval('rhn_sourcerpm_id_seq'), name_in);
		source_id := currval('rhn_sourcerpm_id_seq');
	END IF;
        
        RETURN source_id;
END;
$$
LANGUAGE PLPGSQL;
