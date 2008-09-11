--
--$Id$
--
-- 
--

--data for rhn_config_security_type

insert into rhn_config_security_type(name,description) 
    values ( 'INTERNAL','Internal-only configuration parameters');
insert into rhn_config_security_type(name,description) 
    values ( 'EXTERNAL','Exportable configuration parameters');
insert into rhn_config_security_type(name,description) 
    values ( 'ALL','All security levels');
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
