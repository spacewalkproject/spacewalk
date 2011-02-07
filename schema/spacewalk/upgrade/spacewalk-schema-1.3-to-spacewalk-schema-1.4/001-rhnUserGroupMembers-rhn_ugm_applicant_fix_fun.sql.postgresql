-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create or replace function rhn_ugm_applicant_fix_fun() returns trigger
as
$$
declare
        group_type_val    NUMERIC;
        group_label_val   rhnUserGroupType.label%TYPE;
begin
        SELECT group_type INTO group_type_val
          FROM rhnUserGroup
         WHERE id = old.user_group_id;

        IF group_type_val IS NOT NULL
        THEN
            SELECT label INTO group_label_val
              FROM rhnUserGroupType
             WHERE id = group_type_val;

            IF group_label_val = 'org_applicant'
            THEN
                UPDATE web_contact SET password = old_password WHERE id = old.user_id;
            END IF;
        END IF;
	return new;
end;
$$ LANGUAGE PLPGSQL;

