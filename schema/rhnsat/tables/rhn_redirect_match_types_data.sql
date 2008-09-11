--
--$Id$
--
-- 
--

--data for rhn_redirect_match_types

insert into rhn_redirect_match_types(name) 
    values ( 'CASE_SEN_MSG_PATTERN');
insert into rhn_redirect_match_types(name) 
    values ( 'CASE_INSEN_MSG_PATTERN');
insert into rhn_redirect_match_types(name) 
    values ( 'PROBE_ID');
insert into rhn_redirect_match_types(name) 
    values ( 'NETSAINT_ID');
insert into rhn_redirect_match_types(name) 
    values ( 'PROBE_TYPE');
insert into rhn_redirect_match_types(name) 
    values ( 'SERVICE_STATE');
insert into rhn_redirect_match_types(name) 
    values ( 'HOST_STATE');
insert into rhn_redirect_match_types(name) 
    values ( 'CONTACT_GROUP_ID');
insert into rhn_redirect_match_types(name) 
    values ( 'CONTACT_METHOD_ID');
insert into rhn_redirect_match_types(name) 
    values ( 'CUSTOMER_ID');
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
