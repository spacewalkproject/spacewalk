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
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'tasks',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'critical-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'critical-probes','show_monitoring();');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'warning-probes','show_monitoring();');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'system-groups-widget','org_entitlement(sw_mgr_enterprise);');
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'latest-errata',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'inactive-systems',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval,'pending-actions',null);
insert into RHNINFOPANE(ID,LABEL,ACL) values (rhn_info_pane_id_seq.nextval, 'recently-registered-systems', null);
