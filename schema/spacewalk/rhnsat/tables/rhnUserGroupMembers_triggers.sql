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

create or replace trigger
rhn_ug_member_mod_trig
before insert or update on rhnUserGroupMembers
for each row
declare
        ug              rhnUserGroup%ROWTYPE;
begin
        :new.modified := sysdate;

        if inserting then
                select
                        * into ug
                from
                        rhnUserGroup
                where
                        id = :new.user_group_id;

                if ug.max_members is not null and
                ug.current_members+1 > ug.max_members then
                        rhn_exception.raise_exception('usergroup_max_members');
                end if;

                update rhnUserGroup
                set current_members = current_members + 1
                where id = :new.user_group_id;
        end if;
end;
/
show errors

CREATE OR REPLACE TRIGGER
rhn_user_group_org_mapping
BEFORE INSERT OR UPDATE ON rhnUserGroupMembers
FOR EACH ROW
DECLARE
        same_org        NUMBER;
BEGIN
        same_org := 0;
        SELECT 1 INTO same_org
          FROM web_contact U, rhnUserGroup UG
         WHERE UG.org_id = U.org_id
           AND U.id = :new.user_id
           AND UG.id = :new.user_group_id;

        IF same_org = 0 THEN
          rhn_exception.raise_exception('ugm_different_orgs');
        END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          rhn_exception.raise_exception('ugm_different_orgs');
END;
/
SHOW ERRORS


create or replace trigger
rhn_ug_member_del_trig
before delete on rhnUserGroupMembers
for each row
begin
        update rhnUserGroup
        set current_members = current_members - 1
        where id = :old.user_group_id;
end;
/
show errors

create or replace trigger
rhn_ugm_applicant_fix
after delete on rhnUserGroupMembers
for each row
declare
    	group_type_val    NUMBER;
    	group_label_val   rhnUserGroupType.label%TYPE;	
begin
    	SELECT group_type INTO group_type_val
	  FROM rhnUserGroup
	 WHERE id = :old.user_group_id;
	 
	IF group_type_val IS NOT NULL
	THEN
	    SELECT label INTO group_label_val
	      FROM rhnUserGroupType
	     WHERE id = group_type_val;
	     
	    IF group_label_val = 'org_applicant'
	    THEN
	    	UPDATE web_contact SET password = old_password WHERE id = :old.user_id;
	    END IF;
	END IF;
end;
/
show errors

--
-- Revision 1.6  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
