--
--$Id$
--
-- 
--
--data for rhn_os (no sequence) 
--linux and scouts only

insert into rhn_os(recid,os_name) 
    values ( 4,'Linux System');
insert into rhn_os(recid,os_name) 
    values ( 14,'Satellite');

commit;


--$Log$
--Revision 1.4  2004/06/17 20:25:18  kja
--bugzilla 124620 -- Include only approved probes.  Fixed data referential
--integrity errors.  Only approved operating systems.
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
