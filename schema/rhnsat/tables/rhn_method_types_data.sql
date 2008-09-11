--
--$Id$
--
-- 
--

--data for rhn_method_types (no sequence)

insert into rhn_method_types(recid,method_type_name,notification_format_id) 
    values ( 1,'Pager',5);
insert into rhn_method_types(recid,method_type_name,notification_format_id) 
    values ( 2,'Email',4);
insert into rhn_method_types(recid,method_type_name,notification_format_id) 
    values ( 4,'Group',4);
insert into rhn_method_types(recid,method_type_name,notification_format_id) 
    values ( 5,'SNMP',4);
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
