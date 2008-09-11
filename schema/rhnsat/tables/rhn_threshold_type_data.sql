--
--$Id$
--
-- 
--

--data for rhn_threshold_type

insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'warn_min','Minimum',10,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'warn_max','Maximum',20,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'crit_min','Minimum',0,'system',sysdate);
insert into rhn_threshold_type(name,description,ordinal,last_update_user,
last_update_date) 
    values ( 'crit_max','Maximum',30,'system',sysdate);
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
