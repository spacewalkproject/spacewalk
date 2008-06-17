-- created by Oraschemadoc Fri Jun 13 14:06:10 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE TRIGGER "RHNSAT"."RHN_SERVERGROUP_NOTE_MOD_TRIG" 
BEFORE INSERT OR UPDATE ON rhnServerGroupNotes
FOR EACH ROW
BEGIN
        :new.modified := sysdate;
END;
ALTER TRIGGER "RHNSAT"."RHN_SERVERGROUP_NOTE_MOD_TRIG" ENABLE
 
/
