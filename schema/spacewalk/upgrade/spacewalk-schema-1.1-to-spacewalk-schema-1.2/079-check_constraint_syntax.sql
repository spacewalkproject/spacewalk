
set serveroutput on


begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTION_ARCHIVED_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'archived in (0, 1)') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTION drop constraint RHN_ACTION_ARCHIVED_CK';
			end if;
			execute immediate 'alter table RHNACTION add constraint RHN_ACTION_ARCHIVED_CK check (archived in (0, 1)) novalidate';
			dbms_output.put_line('Recreating RHN_ACTION_ARCHIVED_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTIONCD_FILE_IC_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'import_contents in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONCONFIGDATE drop constraint RHN_ACTIONCD_FILE_IC_CK';
			end if;
			execute immediate 'alter table RHNACTIONCONFIGDATE add constraint RHN_ACTIONCD_FILE_IC_CK check (import_contents in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACTIONCD_FILE_IC_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTIONCD_FILE_FT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'file_type in (''W'',''B'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONCONFIGDATEFILE drop constraint RHN_ACTIONCD_FILE_FT_CK';
			end if;
			execute immediate 'alter table RHNACTIONCONFIGDATEFILE add constraint RHN_ACTIONCD_FILE_FT_CK check (file_type in (''W'',''B'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACTIONCD_FILE_FT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTIONDC_REST_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'restart in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONDAEMONCONFIG drop constraint RHN_ACTIONDC_REST_CK';
			end if;
			execute immediate 'alter table RHNACTIONDAEMONCONFIG add constraint RHN_ACTIONDC_REST_CK check (restart in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACTIONDC_REST_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACT_P_PARAM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'parameter IN (''upgrade'', ''install'', ''remove'', ''downgrade'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONPACKAGE drop constraint RHN_ACT_P_PARAM_CK';
			end if;
			execute immediate 'alter table RHNACTIONPACKAGE add constraint RHN_ACT_P_PARAM_CK check (parameter IN (''upgrade'', ''install'', ''remove'', ''downgrade'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACT_P_PARAM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTION_TYPE_TRIGSNAP_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'trigger_snapshot in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONTYPE drop constraint RHN_ACTION_TYPE_TRIGSNAP_CK';
			end if;
			execute immediate 'alter table RHNACTIONTYPE add constraint RHN_ACTION_TYPE_TRIGSNAP_CK check (trigger_snapshot in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACTION_TYPE_TRIGSNAP_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ACTION_TYPE_UNLCK_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'unlocked_only in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNACTIONTYPE drop constraint RHN_ACTION_TYPE_UNLCK_CK';
			end if;
			execute immediate 'alter table RHNACTIONTYPE add constraint RHN_ACTION_TYPE_UNLCK_CK check (unlocked_only in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ACTION_TYPE_UNLCK_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ALLOW_TRUST_CHANNELFLG_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'channel_flag in (''N'',''Y'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNALLOWTRUST drop constraint RHN_ALLOW_TRUST_CHANNELFLG_CK';
			end if;
			execute immediate 'alter table RHNALLOWTRUST add constraint RHN_ALLOW_TRUST_CHANNELFLG_CK check (channel_flag in (''N'',''Y'')) novalidate';
			dbms_output.put_line('Recreating RHN_ALLOW_TRUST_CHANNELFLG_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ALLOW_TRUST_MIGRFLG_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'migration_flag in (''N'',''Y'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNALLOWTRUST drop constraint RHN_ALLOW_TRUST_MIGRFLG_CK';
			end if;
			execute immediate 'alter table RHNALLOWTRUST add constraint RHN_ALLOW_TRUST_MIGRFLG_CK check (migration_flag in (''N'',''Y'')) novalidate';
			dbms_output.put_line('Recreating RHN_ALLOW_TRUST_MIGRFLG_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CHANNEL_RU_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'receiving_updates in (''Y'', ''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNCHANNEL drop constraint RHN_CHANNEL_RU_CK';
			end if;
			execute immediate 'alter table RHNCHANNEL add constraint RHN_CHANNEL_RU_CK check (receiving_updates in (''Y'', ''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_CHANNEL_RU_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CHANNELPROD_BETA_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'beta in (''Y'', ''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNCHANNELPRODUCT drop constraint RHN_CHANNELPROD_BETA_CK';
			end if;
			execute immediate 'alter table RHNCHANNELPRODUCT add constraint RHN_CHANNELPROD_BETA_CK check (beta in (''Y'', ''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_CHANNELPROD_BETA_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CONFCONTENT_ISBIN_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'is_binary in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNCONFIGCONTENT drop constraint RHN_CONFCONTENT_ISBIN_CK';
			end if;
			execute immediate 'alter table RHNCONFIGCONTENT add constraint RHN_CONFCONTENT_ISBIN_CK check (is_binary in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_CONFCONTENT_ISBIN_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ERRATA_ADV_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'advisory_type in (''Bug Fix Advisory'',
				                            ''Product Enhancement Advisory'',
							    ''Security Advisory'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNERRATA drop constraint RHN_ERRATA_ADV_TYPE_CK';
			end if;
			execute immediate 'alter table RHNERRATA add constraint RHN_ERRATA_ADV_TYPE_CK check (advisory_type in (''Bug Fix Advisory'',
				                            ''Product Enhancement Advisory'',
							    ''Security Advisory'')) novalidate';
			dbms_output.put_line('Recreating RHN_ERRATA_ADV_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ERRATA_LM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'locally_modified in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNERRATA drop constraint RHN_ERRATA_LM_CK';
			end if;
			execute immediate 'alter table RHNERRATA add constraint RHN_ERRATA_LM_CK check (locally_modified in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ERRATA_LM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ERRATATMP_ADV_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'advisory_type in (''Bug Fix Advisory'',
				                            ''Product Enhancement Advisory'',
							    ''Security Advisory'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNERRATATMP drop constraint RHN_ERRATATMP_ADV_TYPE_CK';
			end if;
			execute immediate 'alter table RHNERRATATMP add constraint RHN_ERRATATMP_ADV_TYPE_CK check (advisory_type in (''Bug Fix Advisory'',
				                            ''Product Enhancement Advisory'',
							    ''Security Advisory'')) novalidate';
			dbms_output.put_line('Recreating RHN_ERRATATMP_ADV_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_ERRATATMP_LM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'locally_modified in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNERRATATMP drop constraint RHN_ERRATATMP_LM_CK';
			end if;
			execute immediate 'alter table RHNERRATATMP add constraint RHN_ERRATATMP_LM_CK check (locally_modified in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_ERRATATMP_LM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSCOMMANDNAME_REQRD_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' required in (''Y'', ''N'') ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTCOMMANDNAME drop constraint RHN_KSCOMMANDNAME_REQRD_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTCOMMANDNAME add constraint RHN_KSCOMMANDNAME_REQRD_CK check ( required in (''Y'', ''N'') ) novalidate';
			dbms_output.put_line('Recreating RHN_KSCOMMANDNAME_REQRD_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSCOMMANDNAME_USES_ARGS_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'uses_arguments in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTCOMMANDNAME drop constraint RHN_KSCOMMANDNAME_USES_ARGS_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTCOMMANDNAME add constraint RHN_KSCOMMANDNAME_USES_ARGS_CK check (uses_arguments in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KSCOMMANDNAME_USES_ARGS_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSD_CMF_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'cfg_management_flag in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTDEFAULTS drop constraint RHN_KSD_CMF_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTDEFAULTS add constraint RHN_KSD_CMF_CK check (cfg_management_flag in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KSD_CMF_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSD_RMF_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'remote_command_flag in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTDEFAULTS drop constraint RHN_KSD_RMF_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTDEFAULTS add constraint RHN_KSD_RMF_CK check (remote_command_flag in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KSD_RMF_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSSCRIPT_CHROOT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'chroot in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTSCRIPT drop constraint RHN_KSSCRIPT_CHROOT_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTSCRIPT add constraint RHN_KSSCRIPT_CHROOT_CK check (chroot in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KSSCRIPT_CHROOT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KSSCRIPT_ST_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'script_type in (''pre'',''post'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKICKSTARTSCRIPT drop constraint RHN_KSSCRIPT_ST_CK';
			end if;
			execute immediate 'alter table RHNKICKSTARTSCRIPT add constraint RHN_KSSCRIPT_ST_CK check (script_type in (''pre'',''post'')) novalidate';
			dbms_output.put_line('Recreating RHN_KSSCRIPT_ST_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_ACTIVE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'active in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_ACTIVE_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_ACTIVE_CK check (active in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_ACTIVE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_DEFAULT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'is_org_default in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_DEFAULT_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_DEFAULT_CK check (is_org_default in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_DEFAULT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_CFG_SAVE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'kscfg in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_CFG_SAVE_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_CFG_SAVE_CK check (kscfg in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_CFG_SAVE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_NONCHROOT_POST_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'nonchrootpost in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_NONCHROOT_POST_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_NONCHROOT_POST_CK check (nonchrootpost in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_NONCHROOT_POST_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_POST_LOG_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'postLog in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_POST_LOG_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_POST_LOG_CK check (postLog in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_POST_LOG_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_PRE_LOG_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'preLog in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_PRE_LOG_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_PRE_LOG_CK check (preLog in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_PRE_LOG_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_KS_VERBOSE_UP2DATE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'verboseup2date in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNKSDATA drop constraint RHN_KS_VERBOSE_UP2DATE_CK';
			end if;
			execute immediate 'alter table RHNKSDATA add constraint RHN_KS_VERBOSE_UP2DATE_CK check (verboseup2date in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_KS_VERBOSE_UP2DATE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_REG_TOKEN_DEPLOYCONFS_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'deploy_configs in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNREGTOKEN drop constraint RHN_REG_TOKEN_DEPLOYCONFS_CK';
			end if;
			execute immediate 'alter table RHNREGTOKEN add constraint RHN_REG_TOKEN_DEPLOYCONFS_CK check (deploy_configs in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_REG_TOKEN_DEPLOYCONFS_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SAVEDSEARCH_SSET_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' search_set in (''all'',''system_list'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSAVEDSEARCH drop constraint RHN_SAVEDSEARCH_SSET_CK';
			end if;
			execute immediate 'alter table RHNSAVEDSEARCH add constraint RHN_SAVEDSEARCH_SSET_CK check ( search_set in (''all'',''system_list'')) novalidate';
			dbms_output.put_line('Recreating RHN_SAVEDSEARCH_SSET_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SAVEDSEARCH_INVERT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'invert in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSAVEDSEARCH drop constraint RHN_SAVEDSEARCH_INVERT_CK';
			end if;
			execute immediate 'alter table RHNSAVEDSEARCH add constraint RHN_SAVEDSEARCH_INVERT_CK check (invert in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SAVEDSEARCH_INVERT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SERVER_DELIVER_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'auto_deliver in (''Y'', ''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVER drop constraint RHN_SERVER_DELIVER_CK';
			end if;
			execute immediate 'alter table RHNSERVER add constraint RHN_SERVER_DELIVER_CK check (auto_deliver in (''Y'', ''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SERVER_DELIVER_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SERVER_UPDATE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'auto_update in (''Y'', ''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVER drop constraint RHN_SERVER_UPDATE_CK';
			end if;
			execute immediate 'alter table RHNSERVER add constraint RHN_SERVER_UPDATE_CK check (auto_update in (''Y'', ''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SERVER_UPDATE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_ATTR_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'attribute in (''c'',''d'',''g'',''l'',''r'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_ATTR_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_ATTR_CK check (attribute in (''c'',''d'',''g'',''l'',''r'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_ATTR_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_DEVNUM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'devnum_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_DEVNUM_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_DEVNUM_CK check (devnum_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_DEVNUM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_GID_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'gid_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_GID_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_GID_CK check (gid_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_GID_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_MODE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'mode_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_MODE_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_MODE_CK check (mode_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_MODE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_MTIME_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'mtime_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_MTIME_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_MTIME_CK check (mtime_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_MTIME_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_READLINK_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'readlink_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_READLINK_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_READLINK_CK check (readlink_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_READLINK_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_SIZE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'size_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_SIZE_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_SIZE_CK check (size_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_SIZE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SACTIONVR_UID_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'uid_differs in (''Y'',''N'',''?'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT drop constraint RHN_SACTIONVR_UID_CK';
			end if;
			execute immediate 'alter table RHNSERVERACTIONVERIFYRESULT add constraint RHN_SACTIONVR_UID_CK check (uid_differs in (''Y'',''N'',''?'')) novalidate';
			dbms_output.put_line('Recreating RHN_SACTIONVR_UID_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SERVERGROUPTYPE_ISBASE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'is_base in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERGROUPTYPE drop constraint RHN_SERVERGROUPTYPE_ISBASE_CK';
			end if;
			execute immediate 'alter table RHNSERVERGROUPTYPE add constraint RHN_SERVERGROUPTYPE_ISBASE_CK check (is_base in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SERVERGROUPTYPE_ISBASE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SERVERGROUPTYPE_PERM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'permanent in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSERVERGROUPTYPE drop constraint RHN_SERVERGROUPTYPE_PERM_CK';
			end if;
			execute immediate 'alter table RHNSERVERGROUPTYPE add constraint RHN_SERVERGROUPTYPE_PERM_CK check (permanent in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SERVERGROUPTYPE_PERM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SOLARIS_PKG_IO_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' intonly in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNSOLARISPACKAGE drop constraint RHN_SOLARIS_PKG_IO_CK';
			end if;
			execute immediate 'alter table RHNSOLARISPACKAGE add constraint RHN_SOLARIS_PKG_IO_CK check ( intonly in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_SOLARIS_PKG_IO_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_TU_ENABLED_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'enabled in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNTINYURL drop constraint RHN_TU_ENABLED_CK';
			end if;
			execute immediate 'alter table RHNTINYURL add constraint RHN_TU_ENABLED_CK check (enabled in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_TU_ENABLED_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_ES_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'agreed_to_es_terms is null or agreed_to_es_terms in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_ES_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_ES_CK check (agreed_to_es_terms is null or agreed_to_es_terms in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_ES_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_AGREED_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'agreed_to_terms in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_AGREED_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_AGREED_CK check (agreed_to_terms in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_AGREED_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_WS_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'agreed_to_ws_terms is null or agreed_to_ws_terms in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_WS_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_WS_CK check (agreed_to_ws_terms is null or agreed_to_ws_terms in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_WS_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_SEA_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'show_applied_errata in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_SEA_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_SEA_CK check (show_applied_errata in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_SEA_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_SSGL_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'show_system_group_list in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_SSGL_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_SSGL_CK check (show_system_group_list in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_SSGL_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_USER_INFO_PAM_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'use_pam_authentication in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHNUSERINFO drop constraint RHN_USER_INFO_PAM_CK';
			end if;
			execute immediate 'alter table RHNUSERINFO add constraint RHN_USER_INFO_PAM_CK check (use_pam_authentication in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating RHN_USER_INFO_PAM_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'CHKPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'probe_type=''check''') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_CHECK_PROBE drop constraint CHKPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_CHECK_PROBE add constraint CHKPB_PROBE_TYPE_CK check (probe_type=''check'') novalidate';
			dbms_output.put_line('Recreating CHKPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CKSPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' probe_type = ''suite'' ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_CHECK_SUITE_PROBE drop constraint RHN_CKSPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_CHECK_SUITE_PROBE add constraint RHN_CKSPB_PROBE_TYPE_CK check ( probe_type = ''suite'' ) novalidate';
			dbms_output.put_line('Recreating RHN_CKSPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_COPTR_PARAM_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'param_type=''threshold''') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_COMMAND_PARAM_THRESHOLD drop constraint RHN_COPTR_PARAM_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_COMMAND_PARAM_THRESHOLD add constraint RHN_COPTR_PARAM_TYPE_CK check (param_type=''threshold'') novalidate';
			dbms_output.put_line('Recreating RHN_COPTR_PARAM_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'CMDTG_TARGET_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'target_type in (''cluster'',''node'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_COMMAND_TARGET drop constraint CMDTG_TARGET_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_COMMAND_TARGET add constraint CMDTG_TARGET_TYPE_CK check (target_type in (''cluster'',''node'')) novalidate';
			dbms_output.put_line('Recreating CMDTG_TARGET_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_CNTGP_ACK_WAIT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' ack_wait < 20160 ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_CONTACT_GROUPS drop constraint RHN_CNTGP_ACK_WAIT_CK';
			end if;
			execute immediate 'alter table RHN_CONTACT_GROUPS add constraint RHN_CNTGP_ACK_WAIT_CK check ( ack_wait < 20160 ) novalidate';
			dbms_output.put_line('Recreating RHN_CNTGP_ACK_WAIT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_HSTPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' probe_type=''host'' ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_HOST_PROBE drop constraint RHN_HSTPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_HOST_PROBE add constraint RHN_HSTPB_PROBE_TYPE_CK check ( probe_type=''host'' ) novalidate';
			dbms_output.put_line('Recreating RHN_HSTPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_RDRCT_REC_DTYPE_VALID' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = ' recurring_dur_type in (12,11,5,3,1) ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_REDIRECTS drop constraint RHN_RDRCT_REC_DTYPE_VALID';
			end if;
			execute immediate 'alter table RHN_REDIRECTS add constraint RHN_RDRCT_REC_DTYPE_VALID check ( recurring_dur_type in (12,11,5,3,1) ) novalidate';
			dbms_output.put_line('Recreating RHN_RDRCT_REC_DTYPE_VALID');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_RDRCT_RECUR_VALID' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'recurring in (0, 1)') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_REDIRECTS drop constraint RHN_RDRCT_RECUR_VALID';
			end if;
			execute immediate 'alter table RHN_REDIRECTS add constraint RHN_RDRCT_RECUR_VALID check (recurring in (0, 1)) novalidate';
			dbms_output.put_line('Recreating RHN_RDRCT_RECUR_VALID');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_RDRCT_RECUR_FREQ_VALID' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'recurring_frequency in (2,3,6)') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_REDIRECTS drop constraint RHN_RDRCT_RECUR_FREQ_VALID';
			end if;
			execute immediate 'alter table RHN_REDIRECTS add constraint RHN_RDRCT_RECUR_FREQ_VALID check (recurring_frequency in (2,3,6)) novalidate';
			dbms_output.put_line('Recreating RHN_RDRCT_RECUR_FREQ_VALID');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_RDRCT_START_LTE_EXPIR' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'start_date <= expiration ') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_REDIRECTS drop constraint RHN_RDRCT_START_LTE_EXPIR';
			end if;
			execute immediate 'alter table RHN_REDIRECTS add constraint RHN_RDRCT_START_LTE_EXPIR check (start_date <= expiration ) novalidate';
			dbms_output.put_line('Recreating RHN_RDRCT_START_LTE_EXPIR');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SATCL_DEPLOYED_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'deployed in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_SAT_CLUSTER drop constraint RHN_SATCL_DEPLOYED_CK';
			end if;
			execute immediate 'alter table RHN_SAT_CLUSTER add constraint RHN_SATCL_DEPLOYED_CK check (deployed in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_SATCL_DEPLOYED_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SATCL_TARGET_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'target_type in (''cluster'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_SAT_CLUSTER drop constraint RHN_SATCL_TARGET_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_SAT_CLUSTER add constraint RHN_SATCL_TARGET_TYPE_CK check (target_type in (''cluster'')) novalidate';
			dbms_output.put_line('Recreating RHN_SATCL_TARGET_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SCLPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'probe_type=''satcluster''') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_SAT_CLUSTER_PROBE drop constraint RHN_SCLPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_SAT_CLUSTER_PROBE add constraint RHN_SCLPB_PROBE_TYPE_CK check (probe_type=''satcluster'') novalidate';
			dbms_output.put_line('Recreating RHN_SCLPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SATND_TARGET_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'target_type in (''node'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_SAT_NODE drop constraint RHN_SATND_TARGET_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_SAT_NODE add constraint RHN_SATND_TARGET_TYPE_CK check (target_type in (''node'')) novalidate';
			dbms_output.put_line('Recreating RHN_SATND_TARGET_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_SNDPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'probe_type=''satnode''') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_SAT_NODE_PROBE drop constraint RHN_SNDPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_SAT_NODE_PROBE add constraint RHN_SNDPB_PROBE_TYPE_CK check (probe_type=''satnode'') novalidate';
			dbms_output.put_line('Recreating RHN_SNDPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_STRAT_ACK_COMP_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'ack_completed in ( ''All'', ''One'',''No'' )') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_STRATEGIES drop constraint RHN_STRAT_ACK_COMP_CK';
			end if;
			execute immediate 'alter table RHN_STRATEGIES add constraint RHN_STRAT_ACK_COMP_CK check (ack_completed in ( ''All'', ''One'',''No'' )) novalidate';
			dbms_output.put_line('Recreating RHN_STRAT_ACK_COMP_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_STRAT_CONT_STRAT_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'contact_strategy in (''Broadcast'',''Escalate'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_STRATEGIES drop constraint RHN_STRAT_CONT_STRAT_CK';
			end if;
			execute immediate 'alter table RHN_STRATEGIES add constraint RHN_STRAT_CONT_STRAT_CK check (contact_strategy in (''Broadcast'',''Escalate'')) novalidate';
			dbms_output.put_line('Recreating RHN_STRAT_CONT_STRAT_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPB_MULTI_STEP_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'multi_step in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE drop constraint RHN_URLPB_MULTI_STEP_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE add constraint RHN_URLPB_MULTI_STEP_CK check (multi_step in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_URLPB_MULTI_STEP_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPB_PROBE_TYPE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'probe_type=''url''') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE drop constraint RHN_URLPB_PROBE_TYPE_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE add constraint RHN_URLPB_PROBE_TYPE_CK check (probe_type=''url'') novalidate';
			dbms_output.put_line('Recreating RHN_URLPB_PROBE_TYPE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPB_RUN_ON_SCOUTS_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'run_on_scouts in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE drop constraint RHN_URLPB_RUN_ON_SCOUTS_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE add constraint RHN_URLPB_RUN_ON_SCOUTS_CK check (run_on_scouts in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_URLPB_RUN_ON_SCOUTS_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPS_COOKIE_SEC_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'cookie_secure in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE_STEP drop constraint RHN_URLPS_COOKIE_SEC_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE_STEP add constraint RHN_URLPS_COOKIE_SEC_CK check (cookie_secure in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_URLPS_COOKIE_SEC_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPS_LOAD_SUB_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'load_subsidiary in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE_STEP drop constraint RHN_URLPS_LOAD_SUB_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE_STEP add constraint RHN_URLPS_LOAD_SUB_CK check (load_subsidiary in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_URLPS_LOAD_SUB_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'RHN_URLPS_VER_LINKS_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'verify_links in (''0'',''1'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table RHN_URL_PROBE_STEP drop constraint RHN_URLPS_VER_LINKS_CK';
			end if;
			execute immediate 'alter table RHN_URL_PROBE_STEP add constraint RHN_URLPS_VER_LINKS_CK check (verify_links in (''0'',''1'')) novalidate';
			dbms_output.put_line('Recreating RHN_URLPS_VER_LINKS_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WEB_CONTACT_IGNORE_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'ignore_flag in (''N'',''Y'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_CONTACT drop constraint WEB_CONTACT_IGNORE_CK';
			end if;
			execute immediate 'alter table WEB_CONTACT add constraint WEB_CONTACT_IGNORE_CK check (ignore_flag in (''N'',''Y'')) novalidate';
			dbms_output.put_line('Recreating WEB_CONTACT_IGNORE_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WUCP_CALL_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'call in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_USER_CONTACT_PERMISSION drop constraint WUCP_CALL_CK';
			end if;
			execute immediate 'alter table WEB_USER_CONTACT_PERMISSION add constraint WUCP_CALL_CK check (call in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating WUCP_CALL_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WUCP_EMAIL_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'email in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_USER_CONTACT_PERMISSION drop constraint WUCP_EMAIL_CK';
			end if;
			execute immediate 'alter table WEB_USER_CONTACT_PERMISSION add constraint WUCP_EMAIL_CK check (email in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating WUCP_EMAIL_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WUCP_FAX_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'fax in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_USER_CONTACT_PERMISSION drop constraint WUCP_FAX_CK';
			end if;
			execute immediate 'alter table WEB_USER_CONTACT_PERMISSION add constraint WUCP_FAX_CK check (fax in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating WUCP_FAX_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WUCP_MAIL_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'mail in (''Y'',''N'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_USER_CONTACT_PERMISSION drop constraint WUCP_MAIL_CK';
			end if;
			execute immediate 'alter table WEB_USER_CONTACT_PERMISSION add constraint WUCP_MAIL_CK check (mail in (''Y'',''N'')) novalidate';
			dbms_output.put_line('Recreating WUCP_MAIL_CK');
		end if;
	end loop;
end;
/

begin
	for i in (
		select constraint_name, constraint_type, search_condition
		from ( select 'WUSI_IPB_CK' x from dual ) d, user_constraints
		where d.x = constraint_name (+)
		) loop
		if i.constraint_name is null or not (i.constraint_type = 'C' and i.search_condition = 'is_po_box in (''1'',''0'')') then
			if i.constraint_name is not null then
				execute immediate 'alter table WEB_USER_SITE_INFO drop constraint WUSI_IPB_CK';
			end if;
			execute immediate 'alter table WEB_USER_SITE_INFO add constraint WUSI_IPB_CK check (is_po_box in (''1'',''0'')) novalidate';
			dbms_output.put_line('Recreating WUSI_IPB_CK');
		end if;
	end loop;
end;
/
