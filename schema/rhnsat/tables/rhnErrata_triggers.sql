--
-- $Id$
--

create or replace trigger
rhn_errata_mod_trig
before insert or update on rhnErrata
for each row
begin
     if ( :new.last_modified = :old.last_modified ) or
        ( :new.last_modified is null )  then
        :new.last_modified := sysdate;
     end if;

	  	:new.modified := sysdate;
end rhn_errata_mod_trig;
/
show errors

--
-- $Log$
-- Revision 1.2  2005/02/10 17:09:45  misa
-- bugzilla: 147534  Fixing the spam problem by properly updating the last_modified field
--
-- Revision 1.1  2004/11/01 21:47:41  pjones
-- bugzilla: none -- rhnErrata's triggers need other tables now
--
