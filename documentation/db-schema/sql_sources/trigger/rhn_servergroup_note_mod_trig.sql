-- created by Oraschemadoc Tue Jul 19 17:31:33 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SERVERGROUP_NOTE_MOD_TRIG" 
BEFORE INSERT OR UPDATE ON rhnServerGroupNotes
FOR EACH ROW
BEGIN
        :new.modified := sysdate;
END;
ALTER TRIGGER "SPACEWALK"."RHN_SERVERGROUP_NOTE_MOD_TRIG" ENABLE
 
/
