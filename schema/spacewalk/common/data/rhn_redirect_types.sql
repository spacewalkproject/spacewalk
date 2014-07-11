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

--data for rhn_redirect_types

insert into rhn_redirect_types(name,description,long_name) 
    values ( 'METOO','Specify a destination for matching alerts (appends to default recipient list)','Supplemental Notification');
insert into rhn_redirect_types(name,description,long_name) 
    values ( 'BLACKHOLE','Clear out default recipient list for matching alerts (i.e. send to nobody, unless other redirects are in effect)','Suspend Standard Notifications');
insert into rhn_redirect_types(name,description,long_name) 
    values ( 'ACK','Automatically acknowlege matching alerts','Automatic Acknowledgement');
insert into rhn_redirect_types(name,description,long_name) 
    values ( 'REDIR','Specify a destination for matching alerts (overrides default recipient list)','Redirect Standard Notifications');
commit;

