--
--$Id$
--
-- 
--

--data for rhn_schedule_types (no sequence)

insert into rhn_schedule_types(recid,description) 
    values ( 1,'Weekly');
insert into rhn_schedule_types(recid,description) 
    values ( 2,'Rotation of Days');
insert into rhn_schedule_types(recid,description) 
    values ( 3,'Rotation of Weeklies');
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
