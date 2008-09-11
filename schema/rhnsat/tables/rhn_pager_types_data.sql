--
--$Id$
--
-- 
--

insert into rhn_pager_types(recid,pager_type_name)
    values ( rhn_pager_types_recid_seq.nextval,'All pager types');
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
--Revision 1.1  2004/04/23 18:27:47  kja
--More reference table data.
--
