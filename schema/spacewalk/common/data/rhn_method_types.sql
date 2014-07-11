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

