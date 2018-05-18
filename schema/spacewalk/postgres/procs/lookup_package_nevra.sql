-- oracle equivalent source sha1 9f3d83ca7b15edbc9013285a8303d725dcd4f006
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
lookup_package_nevra(
        name_id_in in numeric,
        evr_id_in in numeric,
        package_arch_id_in in numeric,
        ignore_null_name in numeric default 0
) returns numeric
as
$$
declare
    nevra_id numeric;
begin
    if ignore_null_name = 1 and name_id_in is null then
        return null;
    end if;

    select id
      into nevra_id
      from rhnPackageNEVRA
     where name_id = name_id_in and
           evr_id = evr_id_in and
           (package_arch_id = package_arch_id_in or
            (package_arch_id is null and package_arch_id_in is null));

    if not found then
        nevra_id := nextval('rhn_pkgnevra_id_seq');

        insert into rhnPackageNEVRA(id, name_id, evr_id, package_arch_id)
            values (nevra_id, name_id_in, evr_id_in, package_arch_id_in)
            on conflict do nothing;

        select id
            into strict nevra_id
            from rhnPackageNEVRA
            where name_id = name_id_in and evr_id = evr_id_in and
                (package_arch_id = package_arch_id_in or
                (package_arch_id is null and package_arch_id_in is null));
    end if;

    return nevra_id;
end;
$$ language plpgsql;
