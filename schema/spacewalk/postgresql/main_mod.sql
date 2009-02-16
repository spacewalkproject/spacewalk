START TRANSACTION;

-- Avoid all the unnecessary NOTICE messages
set client_min_messages = error;

START TRANSACTION;

-- Avoid all the unnecessary NOTICE messages
set client_min_messages = error;

\i rhnCVE.sql
\i rhnPackageName.sql
\i web_customer.sql
\i rhnArchType.sql				
\i rhnChannelArch.sql  			
\i rhnChannelProduct.sql			
\i rhnProductName.sql			
\i rhnChannel.sql				
\i rhnChannelFamily.sql			
\i rhnPublicChannelFamily.sql
\i web_contact.sql
\i rhnPrivateChannelFamily.sql
\i rhnServerArch.sql
\i rhnProvisionState.sql
\i rhnServer.sql
\i rhnServerChannel.sql
\i rhnServerGroupType.sql
\i rhnException.sql
\i rhnServerGroup.sql
\i rhnPackageEVR.sql
\i rhnPackageArch.sql
\i rhnPackageGroup.sql
\i rhnSourceRPM.sql
\i rhnPackage.sql
\i rhnChannelPackage.sql
\i rhnSet.sql
\i rhn_command_groups.sql
\i rhn_command_class.sql
\i rhn_command_requirements.sql
\i rhn_command.sql
\i rhn_probe_types.sql
\i rhn_probe.sql
\i rhn_command_target.sql
\i rhn_physical_location.sql
\i rhn_sat_cluster.sql
\i rhn_check_probe.sql
\i rhn_check_suites.sql
\i rhn_check_suite_probe.sql
\i rhn_command_center_state.sql
\i rhn_widget.sql
\i rhn_semantic_data_type.sql
\i rhn_command_parameter.sql
\i rhn_command_queue_commands.sql
\i rhn_command_queue_execs_bk.sql
\i rhn_command_queue_instances.sql
\i rhn_command_queue_execs.sql
\i rhn_command_queue_instances_bk.sql
\i rhn_command_queue_params.sql
\i rhn_command_queue_sessions.sql
\i rhn_config_group.sql
\i rhn_environment.sql
\i rhn_config_macro.sql
\i rhn_config_security_type.sql
\i rhn_config_parameter.sql
\i rhn_method_types.sql
\i rhn_pager_types.sql
\i rhn_schedule_types.sql
\i rhn_schedules.sql
\i rhn_time_zone_names.sql
\i rhn_notification_formats.sql
\i rhnTimezone.sql
\i rhnUserInfo.sql
\i rhn_contact_methods.sql
\i rhn_strategies.sql
\i rhn_contact_groups.sql
\i rhn_contact_group_members.sql
\i web_user_prefix.sql
\i web_user_personal_info.sql
\i rhn_current_alerts.sql
\i rhn_current_state_summaries.sql
\i rhn_db_environment.sql
\i rhn_deployed_probe.sql
\i rhn_host_probe.sql
\i rhn_host_check_suites.sql
\i rhn_os.sql
\i rhn_server_monitoring_info.sql
\i rhnServerNetInterface.sql
\i rhn_interface_monitoring.sql
\i rhn_ll_netsaint.sql
\i rhn_quanta.sql
\i rhn_units.sql
\i rhn_metrics.sql
\i rhn_multi_scout_threshold.sql
\i rhn_notifservers.sql
\i rhn_os_commands_xref.sql
\i rhn_probe_param_value.sql
\i rhn_probe_state.sql
\i rhn_redirect_types.sql
\i rhn_redirects.sql
\i rhn_redirect_match_types.sql
\i rhn_redirect_criteria.sql
\i rhn_redirect_email_targets.sql
\i rhn_redirect_group_targets.sql
\i rhn_redirect_method_targets.sql
\i rhn_sat_cluster_probe.sql
\i rhn_satellite_state.sql
\i rhn_sat_node.sql
\i rhn_sat_node_probe.sql
\i rhn_schedule_days_norm.sql
\i rhn_schedule_days.sql
\i rhn_schedule_weeks.sql
\i rhn_service_probe_origins.sql
\i rhn_snmp_alert.sql
\i rhn_threshold_type.sql
\i rhn_url_probe.sql
\i rhn_url_probe_step.sql
\i PXTSessions.sql
\i rhnActionType.sql
\i rhnAction.sql
\i rhnActionStatus.sql
\i rhnServerAction.sql
\i rhnConfigChannelType.sql
\i rhnConfigChannel.sql
\i rhnActionConfigChannel.sql
\i rhnActionConfigDateFile.sql
\i rhnActionConfigDate.sql
\i rhnConfigFileName.sql
\i rhnConfigFileFailure.sql
\i rhnConfigFileState.sql
\i rhnConfigFile.sql
\i rhnConfigInfo.sql
\i rhnConfigContent.sql
\i rhnConfigFileType.sql
\i rhnConfigRevision.sql
\i rhnActionConfigFileName.sql
\i rhnActionConfigRevision.sql
\i rhnActionConfigRevisionResult.sql
\i rhnActionDaemonConfig.sql
\i rhnErrataSeverity.sql
\i rhnErrata.sql
\i rhnActionErrataUpdate.sql
\i rhnKSTreeType.sql
\i rhnKSInstallType.sql
\i rhnKickstartableTree.sql
\i rhnActionKickstart.sql
\i rhnFileList.sql
\i rhnActionKickstartFileList.sql
\i rhnKSData.sql
\i rhnKickstartSessionState.sql
\i rhnServerProfileType.sql
\i rhnServerProfile.sql
\i rhnKickstartVirtualizationType.sql
\i rhnKickstartSession.sql
\i rhnActionKickstartGuest.sql
\i rhnActionPackage.sql
\i rhnActionPackageAnswerfile.sql
\i rhnPackageDelta.sql
\i rhnActionPackageDelta.sql
\i rhnActionPackageOrder.sql
\i rhnPackageCapability.sql
\i rhnActionPackageRemovalFailure.sql
\i rhnActionScript.sql
\i rhnTransaction.sql
\i rhnActionTransactions.sql
\i rhnActionVirtDestroy.sql
\i rhnActionVirtReboot.sql
\i rhnActionVirtRefresh.sql
\i rhnActionVirtResume.sql
\i rhnActionVirtSchedulePoller.sql
\i rhnActionVirtSetMemory.sql
\i rhnActionVirtShutdown.sql
\i rhnActionVirtStart.sql
\i rhnActionVirtSuspend.sql
\i rhnActionVirtVcpu.sql
\i rhnRegToken.sql
\i rhnActivationKey.sql
\i rhnAllowTrust.sql
\i rhnAppInstallInstance.sql
\i rhnAppInstallSession.sql
\i rhnAppInstallSessionData.sql
\i rhnArchTypeActions.sql
\i rhnBeehivePathMap.sql
\i rhnPackageNEVRA.sql
\i rhnErrataFileType.sql
\i rhnSnapshotInvalidReason.sql
\i rhnTagName.sql
\i rhnTag.sql
\i rhnBlacklistObsoletes.sql
\i rhnChannelComps.sql
\i rhnChannelCloned.sql
\i rhnFile.sql
\i rhnDownloadType.sql
\i rhnDownloads.sql
\i rhnChannelDownloads.sql
\i rhnChannelErrata.sql
\i rhnChannelFamilyMembers.sql
\i rhnVirtSubLevel.sql
\i rhnChannelFamilyVirtSubLevel.sql
\i rhnChannelNewestPackageAudit.sql
\i rhnChannelNewestPackage.sql
\i rhnChannelPackageArchCompat.sql
\i rhnSnapshot.sql
\i rhnSnapshotChannel.sql
\i rhnChannelParent.sql
\i rhnChannelPermissionRole.sql
\i rhnChannelPermission.sql
\i rhnChannelTrust.sql
\i rhnClientCapabilityName.sql
\i rhnClientCapability.sql
\i rhn_command_param_threshold.sql
\i rhnSnapshotConfigChannel.sql
\i rhnSnapshotConfigRevision.sql
\i rhnOrgQuota.sql
\i rhnCpuArch.sql
\i rhnCpu.sql
\i rhnCryptoKeyType.sql
\i rhnCryptoKey.sql
\i rhnCryptoKeyKickstart.sql
\i rhnCustomDataKey.sql
\i rhnDaemonState.sql
\i rhnDailySummaryQueue.sql
\i rhnDevice.sql
\i rhnDistChannelMap.sql
\i rhnEmailAddressState.sql
\i rhnEmailAddress.sql
\i rhnEmailAddressLog.sql
\i rhnEntitlementLog.sql
\i rhnErrataBuglist.sql
\i rhnErrataTmp.sql
\i rhnErrataBuglistTmp.sql
\i rhnErrataCloned.sql
\i rhnErrataClonedTmp.sql
\i rhnErrataCVE.sql
\i rhnErrataFile.sql
\i rhnErrataFileChannel.sql
\i rhnErrataFileTmp.sql
\i rhnErrataFileChannelTmp.sql
\i rhnPackageSource.sql
\i rhnErrataPackage.sql
\i rhnErrataFilePackageSource.sql
\i rhnErrataFilePackage.sql
\i rhnErrataFilePackageTmp.sql
\i rhnErrataKeyword.sql
\i rhnErrataKeywordTmp.sql
\i rhnErrataNotificationQueue.sql
\i rhnErrataPackageTmp.sql
\i rhnErrataQueue.sql
\i rhnFAQClass.sql
\i rhnFAQ.sql
\i rhnFeature.sql
\i rhnFileDownload.sql
\i rhnFileListMembers.sql
\i rhnFileLocation.sql
\i rhnGrailComponentChoices.sql
\i rhnUserGroupType.sql
\i rhnGrailComponents.sql
\i rhnIndexerWork.sql
\i rhnInfoPane.sql
\i rhnKickstartChildChannel.sql
\i rhnKickstartCommandName.sql
\i rhnKickstartCommand.sql
\i rhnKickstartDefaultRegToken.sql
\i rhnKickstartDefaults.sql
\i rhnKickstartIPRange.sql
\i rhnKickstartPackage.sql
\i rhnKickstartPreserveFileList.sql
\i rhnKickstartScript.sql
\i rhnKickstartSessionHistory.sql
\i rhnKickstartTimezone.sql
\i rhnKSTreeFile.sql
\i rhnMessagePriority.sql
\i rhnMessageType.sql
\i rhnMessage.sql
\i rhnMonitorGranularity.sql
\i rhnMonitor.sql
\i rhnOrgChannelSettingsType.sql
\i rhnOrgChannelSettings.sql
\i rhnOrgEntitlementType.sql
\i rhnOrgEntitlements.sql
\i rhnOrgErrataCacheQueue.sql
\i rhnOrgInfo.sql
\i rhnPackageChangelog.sql
\i rhnPackageConflicts.sql
\i rhnTransactionOperation.sql
\i rhnTransactionPackage.sql
\i rhnPackageDeltaElement.sql
\i rhnPackageFileDeleteQueue.sql
\i rhnPackageFile.sql
\i rhnPackageKeyType.sql
\i rhnPackageProvider.sql
\i rhnPackageKey.sql
\i rhnPackageKeyAssociation.sql
\i rhnPackageObsoletes.sql
\i rhnPackageProvides.sql
\i rhnPackageRequires.sql
\i rhnPackageSense.sql
\i rhnPackageSenseMap.sql
\i rhnPackageSyncBlacklist.sql
\i rhnPathChannelMap.sql
\i rhnProductLine.sql
\i rhnProduct.sql
\i rhnProductChannel.sql
\i rhnProxyInfo.sql
\i rhnPushClientState.sql
\i rhnPushClient.sql
\i rhnPushDispatcher.sql
\i rhnRam.sql
\i rhnRedHatCanonVersion.sql
\i rhnRegTokenChannels.sql
\i rhnRegTokenConfigChannels.sql
\i rhnRegTokenEntitlement.sql
\i rhnRegTokenGroups.sql
\i rhnRegTokenOrgDefault.sql
\i rhnRegTokenPackages.sql
\i rhnRelationshipType.sql
\i rhnReleaseChannelMap.sql
\i rhnSatelliteCert.sql
\i rhnSatelliteChannelFamily.sql
\i rhnSatelliteInfo.sql
\i rhnSatelliteServerGroup.sql
\i rhnSavedSearchType.sql
\i rhnSavedSearch.sql
\i rhnServerActionPackageResult.sql
\i rhnServerActionScriptResult.sql
\i rhnServerActionVerifyMissing.sql
\i rhnServerActionVerifyResult.sql
\i rhnServerCacheInfo.sql
\i rhnServerChannelArchCompat.sql
\i rhnServerConfigChannel.sql
\i rhnServerCustomDataValue.sql
\i rhnServerDMI.sql
\i rhnServerEvent.sql
\i rhnServerGroupMembers.sql
\i rhnServerGroupNotes.sql
\i rhnUserGroup.sql
\i rhnSnapshotServerGroup.sql
\i rhnServerGroupTypeFeature.sql
\i rhnServerHistory.sql
\i rhnServerInfo.sql
\i rhnServerInstallInfo.sql
\i rhnServerLocation.sql
\i rhnServerLock.sql
\i rhnServerMessage.sql
\i rhnServerNeededErrataCache.sql
\i rhnServerNeededPackageCache.sql
\i rhnServerNetwork.sql
\i rhnServerNotes.sql
\i rhnServerPackageArchCompat.sql
\i rhnServerPackage.sql
\i rhnServerPath.sql
\i rhnServerPreserveFileList.sql
\i rhnServerProfilePackage.sql
\i rhnServerServerGroupArchCompat.sql
\i rhnServerTokenRegs.sql
\i rhnServerUuid.sql
\i rhnSGTypeBaseAddonCompat.sql
\i rhnSGTypeVirtSubLevel.sql
\i rhnSnapshotPackage.sql
\i rhnSnapshotTag.sql
\i rhnSNPErrataQueue.sql
\i rhnSNPServerQueue.sql
\i rhnSolarisPackage.sql
\i rhnSolarisPatchedPackage.sql
\i rhnSolarisPatchPackages.sql
\i rhnSolarisPatchSet.sql
\i rhnSolarisPatchSetMembers.sql
\i rhnSolarisPatchType.sql
\i rhnSolarisPatch.sql
\i rhnSystemMigrations.sql
\i rhnTaskQueue.sql
\i rhnTemplateCategory.sql
\i rhnTemplateString.sql
\i rhnTextMessage.sql
\i rhnTransactionElement.sql
\i rhnTrustedOrgs.sql
\i rhnUserDefaultSystemGroups.sql
\i rhnUserGroupMembers.sql
\i rhnUserInfoPane.sql
\i rhnUserMessageStatus.sql
\i rhnUserMessage.sql
\i rhnUserMessageType.sql
\i rhnUserReserved.sql
\i rhnUserServerGroupPerms.sql
\i rhnUserServerPerms.sql
\i rhnUserServerPrefs.sql
\i rhnVersionInfo.sql
\i rhnVirtualInstance.sql
\i rhnVirtualInstanceEventType.sql
\i rhnVirtualInstanceState.sql
\i rhnVirtualInstanceEventLog.sql
\i rhnVirtualInstanceType.sql
\i rhnVirtualInstanceInfo.sql
\i rhnVirtualInstanceInstallLog.sql
\i rhnVisibleObjects.sql
\i rhnWebContactChangeState.sql
\i rhnWebContactChangeLog.sql
\i state_change.sql
\i time_series.sql
\i valid_countries.sql
\i valid_countries_tl.sql
\i web_customer_notification.sql
\i web_user_contact_permission.sql
\i web_user_site_type.sql
\i web_user_site_info.sql


/* triggers go here */
\i triggers/rhnOrgQuota.sql
-- \i triggers/rhnActionConfigChannel.sql
-- \i triggers/rhnActionConfigDateFile.sql
-- \i triggers/rhnActionConfigDate.sql
-- \i triggers/rhnActionConfigFileName.sql
-- \i triggers/rhnActionConfigRevisionResult.sql
-- \i triggers/rhnActionConfigRevision.sql
-- \i triggers/rhnActionDaemonConfig.sql
-- \i triggers/rhnActionKickstartFileList.sql
-- \i triggers/rhnActionKickstartGuest.sql
-- \i triggers/rhnActionKickstart.sql
-- \i triggers/rhnActionPackageAnswerfile.sql
-- \i triggers/rhnActionScript.sql
-- \i triggers/rhnAction.sql
-- \i triggers/rhnActionStatus.sql
-- \i triggers/rhnActionVirtDestroy.sql
-- \i triggers/rhnActionVirtReboot.sql
-- \i triggers/rhnActionVirtRefresh.sql
-- \i triggers/rhnActionVirtResume.sql
-- \i triggers/rhnActionVirtSchedulePoller.sql
-- \i triggers/rhnActionVirtSetMemory.sql
-- \i triggers/rhnActionVirtShutdown.sql
-- \i triggers/rhnActionVirtStart.sql
-- \i triggers/rhnActionVirtSuspend.sql
-- \i triggers/rhnActionVirtVcpu.sql
\i triggers/rhnSatelliteCert.sql
\i triggers/web_contact.sql

/* functions go here */
\i procs/create_first_org.sql
\i procs/sequence_nextval.sql
\i procs/sequence_currval.sql
\i procs/lookup_package_key_type.sql
\i procs/create_pxt_session.sql
\i procs/truncateCacheQueue.sql
\i procs/lookup_cf_state.sql
\i procs/queue_errata.sql
\i procs/lookup_arch_type.sql
\i procs/lookup_feature_type.sql
\i procs/lookup_package_provider.sql
\i procs/delete_server_bulk.sql


/* Data population scripts go here */
\i tables/rhnUserGroupType_data.sql
-- \i tables/rhnActionStatus_data.sql
-- \i tables/rhnActionType_data.sql

commit;

/* triggers go here */
\i triggers/rhnOrgQuota.sql
-- \i triggers/rhnActionConfigChannel.sql
-- \i triggers/rhnActionConfigDateFile.sql
-- \i triggers/rhnActionConfigDate.sql
-- \i triggers/rhnActionConfigFileName.sql
-- \i triggers/rhnActionConfigRevisionResult.sql
-- \i triggers/rhnActionConfigRevision.sql
-- \i triggers/rhnActionDaemonConfig.sql
-- \i triggers/rhnActionKickstartFileList.sql
-- \i triggers/rhnActionKickstartGuest.sql
-- \i triggers/rhnActionKickstart.sql
-- \i triggers/rhnActionPackageAnswerfile.sql
-- \i triggers/rhnActionScript.sql
-- \i triggers/rhnAction.sql
-- \i triggers/rhnActionStatus.sql
-- \i triggers/rhnActionVirtDestroy.sql
-- \i triggers/rhnActionVirtReboot.sql
-- \i triggers/rhnActionVirtRefresh.sql
-- \i triggers/rhnActionVirtResume.sql
-- \i triggers/rhnActionVirtSchedulePoller.sql
-- \i triggers/rhnActionVirtSetMemory.sql
-- \i triggers/rhnActionVirtShutdown.sql
-- \i triggers/rhnActionVirtStart.sql
-- \i triggers/rhnActionVirtSuspend.sql
-- \i triggers/rhnActionVirtVcpu.sql
\i triggers/rhnSatelliteCert.sql
\i triggers/web_contact.sql

/* functions go here */
\i procs/create_first_org.sql
\i procs/sequence_nextval.sql
\i procs/sequence_currval.sql
\i procs/lookup_package_key_type.sql
\i procs/create_pxt_session.sql
\i procs/truncateCacheQueue.sql
\i procs/lookup_cf_state.sql
\i procs/queue_errata.sql
\i procs/lookup_arch_type.sql
\i procs/lookup_feature_type.sql
\i procs/lookup_package_provider.sql
\i procs/delete_server_bulk.sql


/* Data population scripts go here */
\i tables/rhnUserGroupType_data.sql
-- \i tables/rhnActionStatus_data.sql
-- \i tables/rhnActionType_data.sql

commit;
