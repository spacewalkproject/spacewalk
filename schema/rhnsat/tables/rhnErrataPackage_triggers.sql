-- 
-- $Id$
--
-- triggers for rhnErrataPackage

create or replace trigger
rhn_errata_package_mod_trig
before insert or update or delete on rhnErrataPackage
for each row
begin
	if inserting or updating then	
		:new.modified := sysdate;
	end if;
	if deleting then
		update rhnErrata
		set rhnErrata.last_modified = sysdate
		where rhnErrata.id in ( :old.errata_id );
	end if;
end rhn_errata_package_mod_trig;
/
show errors

-- $Log$
-- Revision 1.5  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
--
-- Revision 1.4  2004/10/29 18:11:46  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.3  2002/05/07 20:32:10  pjones
-- just time again
--
-- Revision 1.2  2002/04/25 22:38:39  pjones
-- fix log rcs tag
--
