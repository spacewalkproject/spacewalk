-- $Id$
--

create or replace trigger
web_contact_mod_trig
before insert or update on web_contact
for each row
begin
        :new.modified := sysdate;
        :new.login_uc := UPPER(:new.login);
        IF :new.password <> :old.password THEN
                :new.old_password := :old.password;
        END IF;
end;
/
show errors

-- $Log$
-- Revision 1.4  2003/05/07 14:41:48  pjones
-- this should be part of satellite
--
-- Revision 1.3  2002/05/09 17:17:39  pjones
-- move the prop stuff to it's own file and merge the others
--
-- Revision 1.2  2002/05/09 06:22:25  gafton
-- exclude this one from the satellite build
--
