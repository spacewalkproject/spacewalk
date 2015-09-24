-- oracle equivalent source sha1 4931bf72204ed6bb73ade2cdcb226a90c3684cfe

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
create or replace function rhn_ug_member_mod_trig_fun() returns trigger
as
$$
declare
        ug              rhnUserGroup%ROWTYPE;
begin
        new.modified := current_timestamp;

        if tg_op='INSERT'then
                select
                        * into ug
                from
                        rhnUserGroup
                where
                        id = new.user_group_id;

                if ug.max_members is not null and
                ug.current_members+1 > ug.max_members then
                        perform rhn_exception.raise_exception('usergroup_max_members');
                end if;

                update rhnUserGroup
                set current_members = current_members + 1
                where id = new.user_group_id;
        end if;

        return new;
end;
$$
language plpgsql;

create trigger
rhn_ug_member_mod_trig
before insert or update on rhnUserGroupMembers
for each row
execute procedure rhn_ug_member_mod_trig_fun();


CREATE OR REPLACE FUNCTION rhn_user_group_org_mapping_fun() RETURNS TRIGGER
AS
$$
DECLARE
        same_org        NUMERIC;
BEGIN
        same_org := 0;
        SELECT 1 INTO same_org
          FROM web_contact U, rhnUserGroup UG
         WHERE UG.org_id = U.org_id
           AND U.id = new.user_id
           AND UG.id = new.user_group_id;

        IF same_org = 0 THEN
          perform rhn_exception.raise_exception('ugm_different_orgs');
        END IF;

        IF NOT FOUND THEN 
		PERFORM rhn_exception.raise_exception('ugm_different_orgs');
        END IF;

	return new;

END;
$$
LANGUAGE PLPGSQL;


CREATE TRIGGER
rhn_user_group_org_mapping
BEFORE INSERT OR UPDATE ON rhnUserGroupMembers
FOR EACH ROW
EXECUTE PROCEDURE rhn_user_group_org_mapping_fun();


create or replace function rhn_ug_member_del_trig_fun() returns trigger
as
$$
begin
        update rhnUserGroup
        set current_members = current_members - 1
        where id = old.user_group_id;

        return old;
end;
$$
language plpgsql;

create trigger
rhn_ug_member_del_trig
before delete on rhnUserGroupMembers
for each row
execute procedure rhn_ug_member_del_trig_fun();

