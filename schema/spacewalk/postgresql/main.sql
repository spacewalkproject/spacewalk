START TRANSACTION;

-- Avoid all the unnecessary NOTICE messages
set client_min_messages = error;

\i tables/dual.sql
\i tables/web_customer.sql
\i tables/rhnOrgQuota.sql
\i tables/rhnServerGroupType.sql
\i tables/rhnServerGroup.sql
\i tables/rhnUserGroup_sequences.sql
\i tables/rhnUserGroupType.sql
\i tables/rhnUserGroup.sql
\i tables/web_contact.sql
-- \i tables/rhnActionType.sql
-- \i tables/rhnAction.sql
-- \i tables/rhnArchType.sql
-- \i tables/rhnServerArch.sql
-- \i tables/rhnProvisionState.sql
-- \i tables/rhnServer.sql
-- \i tables/rhnConfigChannelType.sql
-- \i tables/rhnConfigChannel.sql
-- \i tables/rhnActionStatus.sql
-- \i tables/rhnServerAction.sql
-- \i tables/rhnActionConfigChannel.sql
-- \i tables/rhnActionConfigDateFile.sql
-- \i tables/rhnActionConfigDate.sql
-- \i tables/rhnConfigFileName.sql
-- \i tables/rhnConfigRevision.sql
-- \i tables/rhnActionConfigFileName.sql
-- \i tables/rhnActionConfigRevisionResult.sql
-- \i tables/rhnActionConfigRevision.sql
-- \i tables/rhnActionDaemonConfig.sql
-- \i tables/rhnActionErrataUpdate.sql
-- \i tables/rhnActionKickstartFileList.sql
-- \i tables/rhnActionKickstartGuest.sql
-- \i tables/rhnActionKickstart.sql
-- \i tables/rhnActionPackageAnswerfile.sql
-- \i tables/rhnActionPackageDelta.sql
-- \i tables/rhnActionPackageOrder.sql
-- \i tables/rhnActionPackageRemovalFailure.sql
-- \i tables/rhnActionPackage.sql
-- \i tables/rhnActionScript.sql
-- \i tables/rhnActionStatus_triggers.sql
-- \i tables/rhnActionTransactions.sql
-- \i tables/rhnActionVirtDestroy.sql
-- \i tables/rhnActionVirtReboot.sql
-- \i tables/rhnActionVirtRefresh.sql
-- \i tables/rhnActionVirtResume.sql
-- \i tables/rhnActionVirtSchedulePoller.sql
-- \i tables/rhnActionVirtSetMemory.sql
-- \i tables/rhnActionVirtShutdown.sql
-- \i tables/rhnActionVirtStart.sql
-- \i tables/rhnActionVirtSuspend.sql
-- \i tables/rhnActionVirtVcpu.sql
\i tables/rhnSatelliteCert.sql

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

\i procs/create_first_org.sql

-- Data population scripts go here
\i tables/rhnUserGroupType_data.sql
-- \i tables/rhnActionStatus_data.sql
-- \i tables/rhnActionType_data.sql

commit;
