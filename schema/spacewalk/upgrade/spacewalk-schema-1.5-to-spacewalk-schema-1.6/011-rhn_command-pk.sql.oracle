alter table rhn_command_param_threshold disable constraint rhn_coptr_cmd_id_cmd_cl_fk;
alter table rhn_command_parameter disable constraint rhn_cparm_cmd_command_id_fk;
alter table rhn_os_commands_xref disable constraint rhn_oscxr_cmmnd_commands_id_fk;
alter table rhn_probe disable constraint rhn_probe_cmmnd_command_id_fk;

-- in spacewalk <0.6 constraint RHN_CMMND_RECID_COMM_CL_UQ had been
-- miscalled RHN_CMMND_NAME_UQ
declare
  cname varchar2(30);
begin
    select constraint_name into cname
      from user_constraints
     where table_name = 'RHN_COMMAND' and index_name = 'RHN_CMMND_RECID_COMM_CL_UQ';
    if cname = 'RHN_CMMND_NAME_UQ' then
        execute immediate 'alter table rhn_command rename constraint RHN_CMMND_NAME_UQ to RHN_CMMND_RECID_COMM_CL_UQ';
    end if;
end;
/
alter table rhn_command disable constraint rhn_cmmnd_recid_comm_cl_uq;
drop index rhn_cmmnd_recid_comm_cl_uq;
alter table rhn_command enable constraint rhn_cmmnd_recid_comm_cl_uq;

alter table rhn_command_param_threshold enable constraint rhn_coptr_cmd_id_cmd_cl_fk;
alter table rhn_command_parameter enable constraint rhn_cparm_cmd_command_id_fk;
alter table rhn_os_commands_xref enable constraint rhn_oscxr_cmmnd_commands_id_fk;
alter table rhn_probe enable constraint rhn_probe_cmmnd_command_id_fk;
