--
-- $Id$
--
-- triggers for rhnUserInfo updates
--

create or replace trigger
rhn_user_info_mod_trig
before insert or update on rhnUserInfo
for each row
begin
	:new.modified := sysdate;
end rhn_user_info_mod_trig;
/
show errors

--
-- $Log$
-- Revision 1.3  2004/11/17 22:04:44  pjones
-- bugzilla: 134953 -- remove the wacky trigger scheme for updating timezone
-- info
--
-- Revision 1.2  2004/11/05 20:48:58  pjones
-- bugzilla: none -- triggers have to be seperated out since they're there for
-- both tables.
--
