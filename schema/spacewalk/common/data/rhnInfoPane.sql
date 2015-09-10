--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'tasks',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'critical-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'system-groups-widget',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'latest-errata',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'inactive-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'),'pending-actions',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (sequence_nextval('rhn_info_pane_id_seq'), 'recently-registered-systems', null);
