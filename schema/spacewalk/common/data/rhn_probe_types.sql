--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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

