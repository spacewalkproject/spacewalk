--
-- $Id$
--
-- data for rhnUserInfo
--
-- EXCLUDE: all

-- create the dummy records
declare
  cursor uinfo is select id user_id from web_contact;
  nrrec number;
begin
	nrrec := 0;
	for info_rec in uinfo loop
	   insert into rhnUserInfo (user_id) values (info_rec.user_id);
	   nrrec := nrrec + 1;
	   if nrrec > 5000 
	   then
	       commit;
	       nrrec := 0;
	   end if;
	end loop;
end;
/
show errors;
commit;

-- $Log$
-- Revision 1.2  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.1  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--


