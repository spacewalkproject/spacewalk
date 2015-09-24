-- oracle equivalent source sha1 9047fa6d92e92c701ac40eed225c67bded199ece
-- retrieved from ./1235730481/28a92ec2f6056ccc56e0bc4b0da3630def22548f/schema/spacewalk/rhnsat/procs/lookup_server_arch.sql
--
-- Copyright (c) 2008--2015 Red Hat, Inc.
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
LOOKUP_SERVER_ARCH(label_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
        server_arch_id          NUMERIC;
BEGIN
        SELECT id
          INTO server_arch_id
          FROM rhnServerArch
         WHERE label = label_in;

         IF NOT FOUND THEN
		perform rhn_exception.raise_exception('server_arch_not_found');
         END IF;

        RETURN server_arch_id;
END;
$$ LANGUAGE PLPGSQL;
