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

insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_package_updates', 'Update Packages',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_errata_updates', 'Errata Updates',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_hardware_refresh', 'Refresh Hardware Profile',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_package_refresh', 'Refresh Packages Profile',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_package_remove', 'Remove Packages',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_auto_errata_updates', 'Auto Errata Update',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_system_grouping', 'System Groups',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_package_verify', 'Verify Packages',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_profile_compare', 'Compare Package Profiles',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_proxy_capable', 'Proxy Capable',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_sat_capable', 'Satellite Capable',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_reboot', 'Reboot System',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_satellite_applet', 'Satellite Applet',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_osa_bus', 'OSA Bus',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_kickstart', 'Kickstart',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_config', 'Config File Management',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_custom_info', 'Custom Information',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_delta_action', 'Package Profile Sync',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_snapshotting', 'System Snapshotting',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_agent_smith', 'Agent Smith',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_remote_command', 'Execute Remote Command',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_schedule_probe', 'Schedule Probe',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_probes', 'Probes',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_nonlinux_support', 'Non-Linux Support',
        sysdate, sysdate);
insert into rhnFeature (id, label, name, created, modified)
values (rhn_feature_seq.nextval, 'ftr_daily_summary', 'Daily Summary',
        sysdate, sysdate);
insert into rhnFeature (id, label, name)
values (rhn_feature_seq.nextval, 'ftr_xen_provision_domain', 'Provision new Xen domains');
insert into rhnFeature (id, label, name)
values (rhn_feature_seq.nextval, 'ftr_xen_manage_domains', 'Manage existing Xen domains');

