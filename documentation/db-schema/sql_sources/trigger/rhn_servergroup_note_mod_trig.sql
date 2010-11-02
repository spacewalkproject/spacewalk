-- created by Oraschemadoc Tue Nov  2 08:33:17 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "SPACEWALK"."RHN_SERVERGROUP_NOTE_MOD_TRIG" 
BEFORE INSERT OR UPDATE ON rhnServerGroupNotes
FOR EACH ROW
BEGIN
        :new.modified := sysdate;
END;
ALTER TRIGGER "SPACEWALK"."RHN_SERVERGROUP_NOTE_MOD_TRIG" ENABLE
 
/
