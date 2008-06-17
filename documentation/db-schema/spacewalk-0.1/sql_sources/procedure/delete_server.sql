-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."DELETE_SERVER" (
	server_id_in in number
) is
	cursor servergroups is
		select	server_id, server_group_id
		from	rhnServerGroupMembers sgm
		where	sgm.server_id = server_id_in;
	cursor configchannels is
		select	cc.id
		from	rhnConfigChannel cc,
			rhnConfigChannelType cct,
			rhnServerConfigChannel scc
		where	1=1
			and scc.server_id = server_id_in
			and scc.config_channel_id = cc.id
			and cct.label in
				('local_override','server_import')
			and cct.id = cc.confchan_type_id;
	cursor filelists is
		select	spfl.file_list_id id
		from	rhnServerPreserveFileList spfl
		where	spfl.server_id = server_id_in
			and not exists (
				select	1
				from	rhnServerPreserveFileList
				where	file_list_id = spfl.file_list_id
					and server_id != server_id_in
				union
				select	1
				from	rhnKickstartPreserveFileList
				where	file_list_id = spfl.file_list_id
			);
	cluster_id number;
    is_virt number := 0;
begin
	rhn_channel.delete_server_channels(server_id_in);
	for filelist in filelists loop
		delete from rhnFileList where id = filelist.id;
	end loop;
	for configchannel in configchannels loop
		rhn_config.delete_channel(configchannel.id);
	end loop;
    begin
      select unique 1 into is_virt
        from rhnServerEntitlementView
       where server_id = server_id_in
         and label in ('virtualization_host', 'virtualization_host_platform');
    exception
      when no_data_found then
        is_virt := 0;
    end;
	for sgm in servergroups loop
		rhn_server.delete_from_servergroup(
			sgm.server_id, sgm.server_group_id);
	end loop;
    if is_virt = 1 then
        rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
    end if;
	update rhnKickstartSession
		set old_server_id = null
		where old_server_id = server_id_in;
	update rhnKickstartSession
		set new_server_id = null
		where new_server_id = server_id_in;
	rhn_channel.clear_subscriptions(server_id_in,1);
        delete from rhnVirtualInstance
	      where host_system_id = server_id_in
		and virtual_system_id is null;
        delete from rhnVirtualInstance
	      where virtual_system_id = server_id_in
	        and host_system_id is null;
    delete from rhnVirtualInstance vi
    where vi.virtual_system_id = server_id_in
    and vi.modified < (select max(vi2.modified)
                    from rhnVirtualInstance vi2
                    where vi2.uuid = vi.uuid);
        update rhnVirtualInstance
	   set host_system_id = null
	 where host_system_id = server_id_in;
	update rhnVirtualInstance
	   set virtual_system_id = null
	 where virtual_system_id = server_id_in;
	update rhnVirtualInstanceEventLog
	   set old_host_system_id = null
         where old_host_system_id = server_id_in;
	update rhnVirtualInstanceEventLog
	   set new_host_system_id = null
         where new_host_system_id = server_id_in;
	delete from rhnActionConfigChannel where server_id = server_id_in;
	delete from rhnActionConfigRevision where server_id = server_id_in;
	delete from rhnActionPackageRemovalFailure where server_id = server_id_in;
	delete from rhnChannelFamilyLicenseConsent where server_id = server_id_in;
	delete from rhnClientCapability where server_id = server_id_in;
	delete from rhnCpu where server_id = server_id_in;
	delete from rhnDevice where server_id = server_id_in;
	delete from rhnProxyInfo where server_id = server_id_in;
	delete from rhnRam where server_id = server_id_in;
	delete from rhnRegToken where server_id = server_id_in;
	delete from rhnSNPServerQueue where server_id = server_id_in;
	delete from rhnSatelliteChannelFamily where server_id = server_id_in;
	delete from rhnSatelliteInfo where server_id = server_id_in;
	delete from rhnServerAction where server_id = server_id_in;
	delete from rhnServerActionPackageResult where server_id = server_id_in;
	delete from rhnServerActionScriptResult where server_id = server_id_in;
	delete from rhnServerActionVerifyResult where server_id = server_id_in;
	delete from rhnServerActionVerifyMissing where server_id = server_id_in;
	delete from rhnServerChannel where server_id = server_id_in;
	delete from rhnServerConfigChannel where server_id = server_id_in;
	delete from rhnServerCustomDataValue where server_id = server_id_in;
	delete from rhnServerDMI where server_id = server_id_in;
	delete from rhnServerMessage where server_id = server_id_in;
	delete from rhnServerEvent where server_id = server_id_in;
	delete from rhnServerHistory where server_id = server_id_in;
	delete from rhnServerInfo where server_id = server_id_in;
	delete from rhnServerInstallInfo where server_id = server_id_in;
	delete from rhnServerLocation where server_id = server_id_in;
	delete from rhnServerLock where server_id = server_id_in;
	delete from rhnServerNeededPackageCache where server_id = server_id_in;
	delete from rhnServerNeededErrataCache where server_id = server_id_in;
	delete from rhnServerNetwork where server_id = server_id_in;
	delete from rhnServerNotes where server_id = server_id_in;
	delete from rhnServerPackage where server_id = server_id_in;
	delete from rhnServerTokenRegs where server_id = server_id_in;
	delete from rhnSnapshotTag where server_id = server_id_in;
	delete from rhnSnapshot where server_id = server_id_in;
	delete from rhnTransaction where server_id = server_id_in;
	delete from rhnUserServerPrefs where server_id = server_id_in;
	delete from rhnServerPath where server_id_in in (server_id, proxy_server_id);
	delete from rhnUserServerPerms where server_id = server_id_in;
	delete from rhn_interface_monitoring where server_id = server_id_in;
	delete from rhnServerNetInterface where server_id = server_id_in;
	delete from rhn_server_monitoring_info where recid = server_id_in;
	delete from rhnAppInstallSession where server_id = server_id_in;
	delete from rhnServerUuid where server_id = server_id_in;
    DELETE FROM rhn_probe_state PS WHERE PS.probe_id in
    (SELECT CP.probe_id
       FROM rhn_check_probe CP
      WHERE CP.host_id = server_id_in
    );
    DELETE FROM rhn_probe P  WHERE P.recid in
    (SELECT CP.probe_id
       FROM rhn_check_probe CP
      WHERE CP.host_id = server_id_in
    );
    DELETE FROM rhn_probe_state PS
      WHERE PS.probe_id in
      (SELECT CP.probe_id
       FROM rhn_check_probe CP
      WHERE CP.sat_cluster_id in
    (SELECT SN.sat_cluster_id
       FROM rhn_sat_node SN
      WHERE SN.server_id = server_id_in));
    DELETE FROM rhn_probe P
       WHERE P.recid in
      (SELECT CP.probe_id
         FROM rhn_check_probe CP
         WHERE CP.sat_cluster_id in
      (SELECT SN.sat_cluster_id
         FROM rhn_sat_node SN
         WHERE SN.server_id = server_id_in));
	delete from rhn_check_probe where host_id = server_id_in;
	delete from rhn_host_probe where host_id = server_id_in;
    delete from rhn_sat_cluster where recid in
      ( select sat_cluster_id from rhn_sat_node where server_id = server_id_in );
	delete from rhn_sat_node where server_id = server_id_in;
	delete
	from	rhnServer
		where id = server_id_in;
	delete
	from	rhnSet
	where	1=1
		and user_id in (
			select	wc.id
			from	rhnServer rs,
				web_contact wc
			where	rs.id = server_id_in
				and rs.org_id = wc.org_id
		)
		and label = 'system_list'
		and element = server_id_in;
end delete_server;
 
/
