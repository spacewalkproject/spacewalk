--
--$Id$
--
-- 
--

--data for rhn_probe_types

insert into rhn_probe_types(probe_type,type_description) 
    values ( 'None','None specified');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'satnode','Satellite Node Probe');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'satcluster','Satellite Cluster Probe');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'url','URL Probe');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'host','Host Probe');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'check','Check Probe');
insert into rhn_probe_types(probe_type,type_description) 
    values ( 'suite','Check Suite Probe');
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
