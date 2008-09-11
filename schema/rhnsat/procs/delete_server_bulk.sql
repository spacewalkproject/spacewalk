-- $Log$
-- Revision 1.25  2004/11/01 17:53:03  pjones
-- bugzilla: 136124 -- Fix the "no data found" when deleting rhn_sat_cluster
--
--
-- $Id$
--
-- This deletes a list of server. 
--

create or replace
procedure delete_server_bulk (
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
			-- these config channel types are reserved
			-- for use by a single server, so we don't
			-- need to check for other servers subscribed
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
				-- this has the org_id just to make the set -much- smaller.
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

	-- it's too bad you can't use "current of" with deletes
	for s in systems loop
		-- we can't use a cursor like planned to for delete_server
		-- to fix rhnKickstartSession entries, because
		-- we miss entries where old_server_id and new_server_id
		-- are both in the set.
		update rhnKickstartSession
			set old_server_id = null
			where old_server_id = s.id;
		update rhnKickstartSession
			set new_server_id = null
			where new_server_id = s.id;
		rhn_channel.clear_subscriptions(s.id,1);

                -- A little complicated here, but the goal is to
		-- delete records from rhnVirtualInstace only if we don't
		-- care about them anymore.  We don't care about records
		-- in rhnVirtualInstance if we are deleting the host
		-- system and the virtual system is already null, or
		-- vice-versa.  We *do* care about them if either the
		-- host or virtual system is still registered because we
		-- still want them to show up in the UI.
				
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
		 
		-- We're deleting everything with a foreign key to rhnServer
		-- here, now.  I'm hoping this will help aleviate our deadlock
		-- problem.

		delete from rhnActionConfigChannel where server_id = s.id;
		delete from rhnActionConfigRevision where server_id = s.id;
		delete from rhnActionPackageRemovalFailure where server_id = s.id;
		delete from rhnChannelFamilyLicenseConsent where server_id = s.id;
		delete from rhnClientCapability where server_id = s.id;
		delete from rhnCpu where server_id = s.id;
		-- there's still a cascade here, because the constraint keeps the
		-- table locked for too long to rebuild it.  Ugh...
		delete from rhnDevice where server_id = s.id;
		delete from rhnProxyInfo where server_id = s.id;
		delete from rhnRam where server_id = s.id;
		delete from rhnRegToken where server_id = s.id;
		delete from rhnSNPServerQueue where server_id = s.id;
		delete from rhnSatelliteChannelFamily where server_id = s.id;
		delete from rhnSatelliteInfo where server_id = s.id;
		-- this cascades to rhnActionConfigChannel and rhnActionConfigFileName
		delete from rhnServerAction where server_id = s.id;
		delete from rhnServerActionPackageResult where server_id = s.id;
		delete from rhnServerActionScriptResult where server_id = s.id;
		delete from rhnServerActionVerifyResult where server_id = s.id;
		delete from rhnServerActionVerifyMissing where server_id = s.id;
		-- counts are handled above.  this should be a delete_ function.
		delete from rhnServerChannel where server_id = s.id;
		delete from rhnServerConfigChannel where server_id = s.id;
		delete from rhnServerCustomDataValue where server_id = s.id;
		delete from rhnServerDMI where server_id = s.id;
		delete from rhnServerMessage where server_id = s.id;
		-- this gets rhnServerMessage (only) on cascade; it's handled just above
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
		-- I'm not removing the foreign key from rhnServerPackage; that'll
		-- take forever.  Do the delete anyway.
		delete from rhnServerPackage where server_id = s.id;
		delete from rhnServerTokenRegs where server_id = s.id;
		delete from rhnSnapshotTag where server_id = s.id;
		-- this cascades to:
		--   rhnSnapshotChannel, rhnSnapshotConfigChannel, rhnSnapshotPackage, 
		--   rhnSnapshotConfigRevision, rhnSnapshotServerGroup, 
		--   rhnSnapshotTag.
		-- We may want to consider delete_snapshot() at some point, but
		--   I don't think we need to yet.
		delete from rhnSnapshot where server_id = s.id;
		delete from rhnTransaction where server_id = s.id;
		delete from rhnUserServerPrefs where server_id = s.id;
		-- hrm, this one's interesting... we _probably_ should delete
		-- everything for the parent server_id when we delete the proxy,
		-- but we don't currently.
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

        -- Now we delete any probes that were using this Server
        -- as a Proxy Scout.
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
show errors;
