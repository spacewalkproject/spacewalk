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
