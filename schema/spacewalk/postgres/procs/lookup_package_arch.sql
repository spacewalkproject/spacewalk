-- oracle equivalent source sha1 f449f76cf3efbbb9ead0b50fc4b6154936a87856
-- retrieved from ./1235730481/28a92ec2f6056ccc56e0bc4b0da3630def22548f/schema/spacewalk/rhnsat/procs/lookup_package_arch.sql
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
LOOKUP_PACKAGE_ARCH(label_in IN VARCHAR)
RETURNS NUMERIC
AS
$$
DECLARE
        package_arch_id         NUMERIC;
BEGIN
   if label_in is null then
      return null;
   end if;

        SELECT id
          INTO package_arch_id
          FROM rhnPackageArch
         WHERE label = label_in;

        IF NOT FOUND THEN
		perform rhn_exception.raise_exception('package_arch_not_found');
        END IF;

       RETURN package_arch_id;

END;
$$
LANGUAGE plpgsql;
