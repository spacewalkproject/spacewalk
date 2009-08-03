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
INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'install', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'rpm'
	   AND ActionT.label = 'packages.update');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'remove', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'rpm'
	   AND ActionT.label = 'packages.remove');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'install', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'sysv-solaris'
	   AND ActionT.label = 'solarispkgs.install');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'remove', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'sysv-solaris'
	   AND ActionT.label = 'solarispkgs.remove');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'install', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'solaris-patch'
	   AND ActionT.label = 'solarispkgs.patchInstall');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'remove', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'solaris-patch'
	   AND ActionT.label = 'solarispkgs.patchRemove');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'install', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'solaris-patch-cluster'
	   AND ActionT.label = 'solarispkgs.patchClusterInstall');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'remove', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
	 WHERE ArchT.label = 'solaris-patch-cluster'
	   AND ActionT.label = 'solarispkgs.patchClusterRemove');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'refresh_list', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
         WHERE ArchT.label = 'sysv-solaris'
           AND ActionT.label = 'solarispkgs.refresh_list');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'refresh_list', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
         WHERE ArchT.label = 'rpm'
           AND ActionT.label = 'packages.refresh_list');

INSERT
  INTO rhnArchTypeActions (arch_type_id, action_style, action_type_id)
       (SELECT ArchT.id, 'verify', ActionT.id
          FROM rhnArchType ArchT, rhnActionType ActionT
         WHERE ArchT.label = 'rpm'
           AND ActionT.label = 'packages.verify');

commit;
