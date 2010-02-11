-- created by Oraschemadoc Fri Jan 22 13:41:02 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_UGM_APPLICANT_FIX"
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
ALTER TRIGGER "SPACEWALK"."RHN_UGM_APPLICANT_FIX" ENABLE
 
/
