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

