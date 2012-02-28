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
lookup_package_capability(name_in in varchar2, version_in in varchar2 default null)
return number
is
    name_id		number;
begin
    if version_in is null then
        select id
          into name_id
          from rhnPackageCapability
         where name = name_in and
               version is null;
    else
        select id
          into name_id
          from rhnPackageCapability
         where name = name_in and
               version = version_in;
	end if;
	return name_id;
exception when no_data_found then
    begin
        name_id := insert_package_capability(name_in, version_in);
    exception when dup_val_on_index then
        if version_in is null then
            select id
              into name_id
              from rhnPackageCapability
             where name = name_in and
                   version is null;
        else
            select id
              into name_id
              from rhnPackageCapability
             where name = name_in and
                   version = version_in;
	end if;

    end;
	return name_id;
end;
/
show errors
