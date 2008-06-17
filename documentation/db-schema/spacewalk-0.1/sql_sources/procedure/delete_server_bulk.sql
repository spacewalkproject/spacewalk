-- created by Oraschemadoc Fri Jun 13 14:06:11 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PROCEDURE "RHNSAT"."DELETE_SERVER_BULK" (
	user_id_in in number
) is
	cursor systems is
		select	s.element id
		from	rhnSet s
		where	s.user_id = user_id_in
			and s.label = 'system_list';
	cursor servergroups is
		select	sgm.server_group_id, sgm.server_id
		from	rhnServerGroupMembers sgm,
			rhnSet s
		where	s.user_id = user_id_in
			and s.label = 'system_list'
			and s.element = sgm.server_id;
	cursor configchannels is
		select	cc.id
		from	rhnConfigChannel cc,
			rhnConfigChannelType cct,
			rhnServerConfigChannel scc,
			rhnSet s
		where	1=1
			and s.user_id = user_id_in
			and s.label = 'system_list'
			and s.element = scc.server_id
			and scc.config_channel_id = cc.id
			and cct.label in
				('local_override','server_import')
			and cct.id = cc.confchan_type_id;
	cursor filelists is
		select	spfl.file_list_id id
		from	rhnServerPreserveFileList spfl,
			rhnSet s
		where	s.user_id = user_id_in
			and s.label = 'system_list'
			and s.element = spfl.server_id
			and not exists (
				select	1
				from	rhnKickstartPreserveFileList
				where	file_list_id = spfl.file_list_id
			)
			and not exists (
				select	spfl.server_id
				from	rhnServerPreserveFileList spfl,
					rhnServer s,
					web_contact u
				where	u.id = user_id_in
					and u.org_id = s.org_id
					and s.id = spfl.server_id
					and spfl.file_list_id = spfl.file_list_id
				minus
				select	element server_id
				from	rhnSet
				where	s.user_id = user_id_in
					and s.label = 'system_list'
			);
	cluster_id number;
    is_virt number := 0;
begin
	for filelist in filelists loop
		delete from rhnFileList where id = filelist.id;
	end loop;
	for cc in configchannels loop
		rhn_config.delete_channel(cc.id);
	end loop;
	for sgm in servergroups loop
        begin
          select 1 into is_virt
            from rhnServerEntitlementView
           where server_id = sgm.server_id
             and label in ('virtualization_host', 'virtualization_host_platform');
        exception
          when no_data_found then
            is_virt := 0;
        end;
		rhn_server.delete_from_servergroup(
			sgm.server_id, sgm.server_group_id);
        if is_virt = 1 then
            rhn_entitlements.repoll_virt_guest_entitlements(sgm.server_id);
        end if;
	end loop;
	for s in systems loop
		update rhnKickstartSession
			set old_server_id = null
			where old_server_id = s.id;
		update rhnKickstartSession
			set new_server_id = null
			where new_server_id = s.id;
		rhn_channel.clear_subscriptions(s.id,1);
                delete from rhnVirtualInstance
		      where host_system_id = s.id
		        and virtual_system_id is null;
                delete from rhnVirtualInstance
		      where virtual_system_id = s.id
		        and host_system_id is null;
		update rhnVirtualInstance
		    	set host_system_id = null
			where host_system_id = s.id;
		update rhnVirtualInstance
		    	set virtual_system_id = null
			where virtual_system_id = s.id;
		update rhnVirtualInstanceEventLog
		   set old_host_system_id = null
 	         where old_host_system_id = s.id;
		update rhnVirtualInstanceEventLog
		   set new_host_system_id = null
 	         where new_host_system_id = s.id;
		delete from rhnActionConfigChannel where server_id = s.id;
		delete from rhnActionConfigRevision where server_id = s.id;
		delete from rhnActionPackageRemovalFailure where server_id = s.id;
		delete from rhnChannelFamilyLicenseConsent where server_id = s.id;
		delete from rhnClientCapability where server_id = s.id;
		delete from rhnCpu where server_id = s.id;
		delete from rhnDevice where server_id = s.id;
		delete from rhnProxyInfo where server_id = s.id;
		delete from rhnRam where server_id = s.id;
		delete from rhnRegToken where server_id = s.id;
		delete from rhnSNPServerQueue where server_id = s.id;
		delete from rhnSatelliteChannelFamily where server_id = s.id;
		delete from rhnSatelliteInfo where server_id = s.id;
		delete from rhnServerAction where server_id = s.id;
		delete from rhnServerActionPackageResult where server_id = s.id;
		delete from rhnServerActionScriptResult where server_id = s.id;
		delete from rhnServerActionVerifyResult where server_id = s.id;
		delete from rhnServerActionVerifyMissing where server_id = s.id;
		delete from rhnServerChannel where server_id = s.id;
		delete from rhnServerConfigChannel where server_id = s.id;
		delete from rhnServerCustomDataValue where server_id = s.id;
		delete from rhnServerDMI where server_id = s.id;
		delete from rhnServerMessage where server_id = s.id;
		delete from rhnServerEvent where server_id = s.id;
		delete from rhnServerHistory where server_id = s.id;
		delete from rhnServerInfo where server_id = s.id;
		delete from rhnServerInstallInfo where server_id = s.id;
		delete from rhnServerLocation where server_id = s.id;
		delete from rhnServerLock where server_id = s.id;
		delete from rhnServerNeededPackageCache where server_id = s.id;
		delete from rhnServerNeededErrataCache where server_id = s.id;
		delete from rhnServerNetwork where server_id = s.id;
		delete from rhnServerNotes where server_id = s.id;
		delete from rhnServerPackage where server_id = s.id;
		delete from rhnServerTokenRegs where server_id = s.id;
		delete from rhnSnapshotTag where server_id = s.id;
		delete from rhnSnapshot where server_id = s.id;
		delete from rhnTransaction where server_id = s.id;
		delete from rhnUserServerPrefs where server_id = s.id;
		delete from rhnServerPath where s.id in (server_id, proxy_server_id);
		delete from rhnUserServerPerms where server_id = s.id;
		delete from rhn_interface_monitoring where server_id = s.id;
		delete from rhnServerNetInterface where server_id = s.id;
		delete from rhn_server_monitoring_info where recid = s.id;
		delete from rhnAppInstallSession where server_id = s.id;
		delete from rhnServerUuid where server_id = s.id;
        DELETE FROM rhn_probe_state PS WHERE PS.probe_id in
        (SELECT CP.probe_id
           FROM rhn_check_probe CP
          WHERE CP.host_id = s.id
        );
        DELETE FROM rhn_probe P  WHERE P.recid in
        (SELECT CP.probe_id
           FROM rhn_check_probe CP
          WHERE CP.host_id = s.id
        );
        DELETE
          FROM rhn_probe_state PS
         WHERE PS.probe_id in
        (SELECT CP.probe_id
           FROM rhn_check_probe CP
          WHERE CP.sat_cluster_id in
        (SELECT SN.sat_cluster_id
           FROM rhn_sat_node SN
          WHERE SN.server_id = s.id));
        DELETE FROM rhn_probe P
         WHERE P.recid in
        (SELECT CP.probe_id
          FROM rhn_check_probe CP
           WHERE CP.sat_cluster_id in
        (SELECT SN.sat_cluster_id
           FROM rhn_sat_node SN
           WHERE SN.server_id = s.id));
        delete from rhn_check_probe where host_id = s.id;
        delete from rhn_host_probe where host_id = s.id;
        delete from rhn_sat_cluster where recid in
         ( select sat_cluster_id from rhn_sat_node where server_id = s.id );
    	delete from rhn_sat_node where server_id = s.id;
		delete from rhnServer
			where id = s.id;
		delete from rhnSet
			where user_id in (
				select	wc.id
				from	rhnServer rs,
					web_contact wc
				where	rs.id = s.id
					and rs.org_id = wc.org_id
			)
			and label = 'system_list'
			and element = s.id;
	end loop;
end delete_server_bulk;
 
/
