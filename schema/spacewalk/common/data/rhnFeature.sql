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
--
-- 

insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_package_updates', 'Update Packages',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_errata_updates', 'Errata Updates',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_hardware_refresh', 'Refresh Hardware Profile',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_package_refresh', 'Refresh Packages Profile',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_package_remove', 'Remove Packages',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_auto_errata_updates', 'Auto Errata Update',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_system_grouping', 'System Groups',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_package_verify', 'Verify Packages',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_profile_compare', 'Compare Package Profiles',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_proxy_capable', 'Proxy Capable',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_sat_capable', 'Satellite Capable',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_reboot', 'Reboot System',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_satellite_applet', 'Satellite Applet',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_osa_bus', 'OSA Bus',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_kickstart', 'Kickstart',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_config', 'Config File Management',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_custom_info', 'Custom Information',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_delta_action', 'Package Profile Sync',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_snapshotting', 'System Snapshotting',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_agent_smith', 'Agent Smith',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_remote_command', 'Execute Remote Command',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name, created, modified)
values (sequence_nextval('rhn_feature_seq'), 'ftr_daily_summary', 'Daily Summary',
        current_timestamp, current_timestamp);
insert into rhnFeature (id, label, name)
values (sequence_nextval('rhn_feature_seq'), 'ftr_xen_provision_domain', 'Provision new Xen domains');
insert into rhnFeature (id, label, name)
values (sequence_nextval('rhn_feature_seq'), 'ftr_xen_manage_domains', 'Manage existing Xen domains');

