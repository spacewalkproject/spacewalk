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

insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_package_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_errata_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_hardware_refresh'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_package_refresh'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_package_remove'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id, 
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_auto_errata_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('sw_mgr_entitled'), lookup_feature_type('ftr_daily_summary'),
        sysdate,sysdate);


insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_package_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_errata_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_hardware_refresh'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_package_refresh'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_package_remove'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_auto_errata_updates'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_system_grouping'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_package_verify'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_profile_compare'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_proxy_capable'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_sat_capable'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_reboot'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_satellite_applet'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_osa_bus'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('enterprise_entitled'), lookup_feature_type('ftr_daily_summary'),
        sysdate,sysdate);


insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_kickstart'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_config'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_custom_info'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_delta_action'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_snapshotting'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_agent_smith'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('provisioning_entitled'), lookup_feature_type('ftr_remote_command'),
        sysdate,sysdate);

insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('monitoring_entitled'), lookup_feature_type('ftr_schedule_probe'),
        sysdate,sysdate);
insert into rhnServerGroupTypeFeature (server_group_type_id, feature_id,
                                       created, modified)
values (lookup_sg_type('monitoring_entitled'), lookup_feature_type('ftr_probes'),
        sysdate,sysdate);

