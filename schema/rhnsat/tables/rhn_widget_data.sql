--
--$Id$
--
-- 
--

--data for rhn_widget

insert into rhn_widget(name,description,last_update_user,last_update_date) 
    values ( 'text','Text','system',sysdate);
insert into rhn_widget(name,description,last_update_user,last_update_date) 
    values ( 'password','Password','system',sysdate);
insert into rhn_widget(name,description,last_update_user,last_update_date) 
    values ( 'checkbox','Checkbox','system',sysdate);
commit;

--$Log$
--Revision 1.4  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--

