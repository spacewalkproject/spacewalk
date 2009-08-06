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
-- data for rhnActionType

-- last two values are for TRIGGER_SNAPSHOT, UNLOCKED_ONLY

insert into rhnActionType values (1, 'packages.refresh_list', 'Package List Refresh', 'Y', 'N');
insert into rhnActionType values (2, 'hardware.refresh_list', 'Hardware List Refresh', 'N', 'N');
insert into rhnActionType values (3, 'packages.update', 'Package Install', 'Y', 'Y');
insert into rhnActionType values (4, 'packages.remove', 'Package Removal', 'Y', 'Y');
insert into rhnActionType values (5, 'errata.update', 'Errata Update', 'Y', 'Y');
insert into rhnActionType values (6, 'up2date_config.get', 'Get server up2date config', 'Y', 'Y');
insert into rhnActionType values (7, 'up2date_config.update', 'Update server up2date config', 'Y', 'Y');
insert into rhnActionType values (8, 'packages.delta', 'Package installation and removal in one RPM transaction', 'Y', 'Y');
insert into rhnActionType values (9, 'reboot.reboot', 'System reboot', 'N', 'Y');
insert into rhnActionType values (10, 'rollback.config', 'Enable or Disable RPM Transaction Rollback', 'N', 'Y');
insert into rhnActionType values (11, 'rollback.listTransactions', 'Refresh server-side transaction list', 'N', 'N');
insert into rhnActionType values (12, 'rollback.rollback', 'RPM Transaction Rollback', 'Y', 'Y');
insert into rhnActionType values (13, 'packages.autoupdate', 'Automatic package installation', 'Y', 'Y');
insert into rhnActionType values (14, 'packages.runTransaction', 'Package Synchronization', 'Y', 'Y');
insert into rhnActionType values (15, 'configfiles.upload', 'Upload config file data to server', 'N', 'N');
insert into rhnActionType values (16, 'configfiles.deploy', 'Deploy config files to system', 'Y', 'Y');
insert into rhnActionType values (17, 'configfiles.verify', 'Verify deployed config files', 'N', 'N');
insert into rhnActionType values (18, 'configfiles.diff', 'Show differences between profiled config files and deployed config files', 'N', 'N');
insert into rhnActionType values (19, 'kickstart.initiate', 'Initiate a kickstart', 'N', 'Y');
insert into rhnActionType values (20, 'kickstart.schedule_sync', 'Schedule a package sync for kickstarts', 'N', 'N');
insert into rhnActionType values (21, 'activation.schedule_pkg_install', 'Schedule a package install for activation key', 'N', 'N');
insert into rhnActionType values (22, 'activation.schedule_deploy', 'Schedule a config deploy for activation key', 'N', 'N');
insert into rhnActionType values (23, 'configfiles.mtime_upload', 'Upload config file data based upon mtime to server', 'N', 'N');
insert into rhnActionType values (24, 'solarispkgs.install', 'Solaris Package Install', 'Y', 'Y');
insert into rhnActionType values (25, 'solarispkgs.remove', 'Solaris Package Removal', 'Y', 'Y');
insert into rhnActionType values (26, 'solarispkgs.patchInstall', 'Solaris Patch Install', 'Y', 'Y');
insert into rhnActionType values (27, 'solarispkgs.patchRemove', 'Solaris Patch Removal', 'Y', 'Y');
insert into rhnActionType values (28, 'solarispkgs.patchClusterInstall', 'Solaris Patch Cluster Install', 'Y', 'Y');
insert into rhnActionType values (29, 'solarispkgs.patchClusterRemove', 'Solaris Patch Cluster Removal', 'Y', 'Y');
insert into rhnActionType values (30, 'script.run', 'Run an arbitrary script', 'N', 'N');
insert into rhnActionType values (31, 'solarispkgs.refresh_list', 'Solaris Package List Refresh','Y','Y');
insert into rhnActionType values (32, 'rhnsd.configure', 'Spacewalk Daemon Configuration','N','N');
insert into rhnActionType values (33, 'packages.verify', 'Verify deployed packages','N','N');
insert into rhnActionType values (34, 'rhn_applet.use_satellite', 'Allows for rhn-applet use with an Spacewalk','N','N');
insert into rhnActionType values (35, 'kickstart_guest.initiate', 'Initiate a kickstart for a virtual guest.','N','Y');
insert into rhnActionType values (36, 'virt.shutdown', 'Shuts down a virtual domain.', 'N', 'N');
insert into rhnActionType values (37, 'virt.start', 'Starts up a virtual domain.', 'N', 'N');
insert into rhnActionType values (38, 'virt.suspend', 'Suspends a virtual domain.', 'N', 'N');
insert into rhnActionType values (39, 'virt.resume', 'Resumes a virtual domain.', 'N', 'N');
insert into rhnActionType values (40, 'virt.reboot', 'Reboots a virtual domain.', 'N', 'N');
insert into rhnActionType values (41, 'virt.destroy', 'Destroys a virtual domain.', 'N', 'N');
insert into rhnActionType values (42, 'virt.setMemory', 'Sets the maximum memory usage for a virtual domain.', 'N', 'N');
insert into rhnActionType values (43, 'virt.schedulePoller', 'Sets when the poller should run.', 'N', 'N');
insert into rhnActionType values (44, 'kickstart_host.schedule_virt_host_pkg_install', 'Schedule a package install of host specific functionality.', 'N', 'N');
insert into rhnActionType values (45, 'kickstart_guest.schedule_virt_guest_pkg_install', 'Schedule a package install of guest specific functionality.', 'N', 'N');
insert into rhnActionType values (46, 'kickstart_host.add_tools_channel', 'Subscribes a server to the Spacewalk Tools channel associated with its base channel.', 'N', 'N');
insert into rhnActionType values (47, 'kickstart_guest.add_tools_channel', 'Subscribes a virtualization guest to the Spacewalk Tools channel associated with its base channel.', 'N', 'N');
insert into rhnActionType values (48, 'virt.setVCPUs', 'Sets the Vcpu usage for a virtual domain.', 'N', 'N');
commit;
insert into rhnActionType values (49, 'proxy.deactivate', 'Deactivate Proxy', 'N', 'N');
--
--
-- Revision 1.25  2004/10/29 05:07:52  pjones
-- bugzilla: 136675 -- remove the new action type we created but aren't using
--
-- Revision 1.24  2004/09/23 16:38:02  pjones
-- bugzilla: 133354 -- fix Robin's engrish.
--
-- Revision 1.23  2004/09/23 14:20:08  pjones
-- bugzilla: 133354 -- add action type to support proxy activation
--
-- Revision 1.22  2004/04/13 16:40:31  bretm
-- bugzilla:  119871
--
-- action type for the applet+satellite scheduled action
--
-- Revision 1.21  2004/04/13 16:26:16  pjones
-- bugzilla: 101315 -- add action type entries for package verify
--
-- Revision 1.20  2004/03/16 19:51:43  misa
-- New action type rhnsd.configure
--
-- Revision 1.19  2004/03/03 16:52:47  pjones
-- bugzilla: none -- something went wrong tagging this, starting over.
--
-- Revision 1.18.2.1  2004/03/03 15:43:13  pjones
-- bugzilla: 117023 -- add solarispkgs.refresh_list
--
-- Revision 1.18  2004/02/17 00:22:59  pjones
-- bugzilla: 115898 -- add the action type for arbitrary scripts
