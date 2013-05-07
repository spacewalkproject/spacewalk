-- Copyright (c) 2008-2012 Red Hat, Inc.
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

create or replace function
lookup_package_group(name_in in varchar2)
return number
is
    package_id   number;
begin
    select id
      into package_id
      from rhnPackageGroup
     where name = name_in;

    return package_id;
exception when no_data_found then
    begin
        package_id := insert_package_group(name_in);
    exception when dup_val_on_index then
        select id
          into package_id
          from rhnPackageGroup
         where name = name_in;
    end;
    return package_id;
end;
/
show errors
