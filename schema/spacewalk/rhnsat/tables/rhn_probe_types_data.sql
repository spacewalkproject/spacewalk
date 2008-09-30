--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
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

--
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
