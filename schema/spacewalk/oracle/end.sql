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

COMMIT;

-- check whether all objects are valid
declare
  invalid_objects number;
begin
  select count(*)
    into invalid_objects
    from user_objects
   where status <> 'VALID';
 if invalid_objects > 0 then
    RAISE_APPLICATION_ERROR(-20001, 'SCHEMA POPULATION ENDS WITH INVALD OBJECTS');
 end if;
end;
/

EXIT

