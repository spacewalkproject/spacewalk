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
-- This deletes a server.  All codepaths which delete servers should hit this
-- or delete_server_bulk()

create or replace
procedure delete_server (
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
			-- these config channel types are reserved
			-- for use by a single server, so we don't
			-- need to check for other servers subscribed
			and cct.label in
				('local_override','server_import')
			and cct.id = cc.confchan_type_id;
        type filelistsid_t is table of rhnServerPreserveFileList.file_list_id%type;
        filelistsid_c filelistsid_t;

        type probesid_t is table of rhn_check_probe.probe_id%type;
        probesid_c probesid_t;

    is_virt number := 0;
begin
	rhn_channel.delete_server_channels(server_id_in);
	-- rhn_channel.clear_subscriptions(server_id_in);

        -- filelists
	select	spfl.file_list_id id bulk collect into filelistsid_c
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
        if filelistsid_c.first is not null then
            forall i in filelistsid_c.first..filelistsid_c.last
                delete from rhnFileList where id = filelistsid_c(i);
        end if;

	for configchannel in configchannels loop
		rhn_config.delete_channel(configchannel.id);
	end loop;

      select count(1) into is_virt
        from rhnServerEntitlementView
       where server_id = server_id_in
         and label in ('virtualization_host', 'virtualization_host_platform')
         and rownum <= 1;

	for sgm in servergroups loop
		rhn_server.delete_from_servergroup(
			sgm.server_id, sgm.server_group_id);
	end loop;

    if is_virt = 1 then
        rhn_entitlements.repoll_virt_guest_entitlements(server_id_in);
    end if;

	-- we're handling this instead of letting an "on delete
	-- set null" do it so that we don't run the risk
	-- of setting off the triggers and killing us with a
	-- mutating table

	-- this is merge of two single updates:
        --  update ... set old_server_id = null where old_server_id = server_id_in;
        --  update ... set new_server_id = null where new_server_id = server_id_in;
        -- so we scan rhnKickstartSession table only once
	update rhnKickstartSession
		set old_server_id = case when old_server_id = server_id_in then null else old_server_id end,
		    new_server_id = case when new_server_id = server_id_in then null else new_server_id end
		where old_server_id = server_id_in 
		   or new_server_id = server_id_in;

	rhn_channel.clear_subscriptions(server_id_in,1);

    	-- A little complicated here, but the goal is to
	-- delete records from rhnVirtualInstace only if we don't
	-- care about them anymore.  We don't care about records
	-- in rhnVirtualInstance if we are deleting the host
	-- system and the virtual system is already null, or
	-- vice-versa.  We *do* care about them if either the
	-- host or virtual system is still registered because we
	-- still want them to show up in the UI.
    -- If there's a newer row in rhnVirtualInstance with the same
    -- uuid, this guest must have been re-registered, so we can clean
    -- this data up.
				
        delete from rhnVirtualInstance vi
	      where (host_system_id = server_id_in and virtual_system_id is null)
                 or (virtual_system_id = server_id_in and host_system_id is null)
                 or (vi.virtual_system_id = server_id_in and vi.modified < (select max(vi2.modified)
                    from rhnVirtualInstance vi2 where vi2.uuid = vi.uuid));
						
        -- this is merge of two single updates:
        --  update ... set host_system_id = null where host_system_id = server_id_in;
        --  update ... set virtual_system_id = null where virtual_system_id = server_id_in;
        -- so we scan rhnVirtualInstance table only once
        update rhnVirtualInstance
	   set host_system_id = case when host_system_id = server_id_in then null else host_system_id end,
	       virtual_system_id = case when virtual_system_id = server_id_in then null else virtual_system_id end
	 where host_system_id = server_id_in
	    or virtual_system_id = server_id_in;
		
        -- this is merge of two single updates:
        --  update ... set old_host_system_id = null when old_host_system_id = server_id_in;
        --  update ... set new_host_system_id = null when new_host_system_id = server_id_in;
        -- so we scan rhnVirtualInstanceEventLog table only once
	update rhnVirtualInstanceEventLog
	   set old_host_system_id = case when old_host_system_id = server_id_in then null else old_host_system_id end,
               new_host_system_id = case when new_host_system_id = server_id_in then null else new_host_system_id end
         where old_host_system_id = server_id_in
            or new_host_system_id = server_id_in;
		 
	-- We're deleting everything with a foreign key to rhnServer
	-- here, now.  I'm hoping this will help aleviate our deadlock
	-- problem.

	delete from rhnActionConfigChannel where server_id = server_id_in;
	delete from rhnActionConfigRevision where server_id = server_id_in;
	delete from rhnActionPackageRemovalFailure where server_id = server_id_in;
	delete from rhnClientCapability where server_id = server_id_in;
	delete from rhnCpu where server_id = server_id_in;
	-- there's still a cascade here, because the constraint keeps the
	-- table locked for too long to rebuild it.  Ugh...
	delete from rhnDevice where server_id = server_id_in;
	delete from rhnProxyInfo where server_id = server_id_in;
	delete from rhnRam where server_id = server_id_in;
	delete from rhnRegToken where server_id = server_id_in;
	delete from rhnSNPServerQueue where server_id = server_id_in;
	delete from rhnSatelliteChannelFamily where server_id = server_id_in;
	delete from rhnSatelliteInfo where server_id = server_id_in;
	-- this cascades to rhnActionConfigChannel and rhnActionConfigFileName
	delete from rhnServerAction where server_id = server_id_in;
	delete from rhnServerActionPackageResult where server_id = server_id_in;
	delete from rhnServerActionScriptResult where server_id = server_id_in;
	delete from rhnServerActionVerifyResult where server_id = server_id_in;
	delete from rhnServerActionVerifyMissing where server_id = server_id_in;
	-- counts are handled above.  this should be a delete_ function.
	delete from rhnServerChannel where server_id = server_id_in;
	delete from rhnServerConfigChannel where server_id = server_id_in;
	delete from rhnServerCustomDataValue where server_id = server_id_in;
	delete from rhnServerDMI where server_id = server_id_in;
	delete from rhnServerMessage where server_id = server_id_in;
	-- this gets rhnServerMessage (only) on cascade; it's handled just above
	delete from rhnServerEvent where server_id = server_id_in;
	delete from rhnServerHistory where server_id = server_id_in;
	delete from rhnServerInfo where server_id = server_id_in;
	delete from rhnServerInstallInfo where server_id = server_id_in;
	delete from rhnServerLocation where server_id = server_id_in;
	delete from rhnServerLock where server_id = server_id_in;
	delete from rhnServerNeededCache where server_id = server_id_in;
	delete from rhnServerNetwork where server_id = server_id_in;
	delete from rhnServerNotes where server_id = server_id_in;
	-- I'm not removing the foreign key from rhnServerPackage; that'll
	-- take forever.  Do the delete anyway.
	delete from rhnServerPackage where server_id = server_id_in;
	delete from rhnServerTokenRegs where server_id = server_id_in;
	delete from rhnSnapshotTag where server_id = server_id_in;
	-- this cascades to:
	--   rhnSnapshotChannel, rhnSnapshotConfigChannel, rhnSnapshotPackage, 
	--   rhnSnapshotConfigRevision, rhnSnapshotServerGroup, 
	--   rhnSnapshotTag.
	-- We may want to consider delete_snapshot() at some point, but
	--   I don't think we need to yet.
	delete from rhnSnapshot where server_id = server_id_in;
	delete from rhnTransaction where server_id = server_id_in;
	delete from rhnUserServerPrefs where server_id = server_id_in;
	-- hrm, this one's interesting... we _probably_ should delete
	-- everything for the parent server_id when we delete the proxy,
	-- but we don't currently.
	delete from rhnServerPath where server_id_in in (server_id, proxy_server_id);
	delete from rhnUserServerPerms where server_id = server_id_in;

	delete from rhn_interface_monitoring where server_id = server_id_in;
	delete from rhnServerNetInterface where server_id = server_id_in;
	delete from rhn_server_monitoring_info where recid = server_id_in;

	delete from rhnAppInstallSession where server_id = server_id_in;
	delete from rhnServerUuid where server_id = server_id_in;
    -- We delete all the probes running directly against this system
    -- and any probes that were using this Server as a Proxy Scout.
     SELECT CP.probe_id bulk collect into probesid_c
       FROM rhn_check_probe CP  
      WHERE CP.host_id = server_id_in
         OR CP.sat_cluster_id in
    (SELECT SN.sat_cluster_id
       FROM rhn_sat_node SN
      WHERE SN.server_id = server_id_in);

    if probesid_c.first is not null then
        FORALL i IN probesid_c.first..probesid_c.last
            DELETE FROM rhn_probe_state PS WHERE PS.probe_id = probesid_c(i);
        FORALL i IN probesid_c.first..probesid_c.last
            DELETE FROM rhn_probe P  WHERE P.recid = probesid_c(i);
        FORALL i IN probesid_c.first..probesid_c.last
            DELETE /*+index(time_series time_series_probe_id_idx)*/
            FROM time_series
            WHERE substr(o_id, instr(o_id, '-') + 1,
                (instr(o_id, '-', instr(o_id, '-') + 1) - instr(o_id, '-'))	- 1) = probesid_c(i);
    end if;

	delete from rhn_check_probe where host_id = server_id_in;
	delete from rhn_host_probe where host_id = server_id_in;

    delete from rhn_sat_cluster where recid in
      ( select sat_cluster_id from rhn_sat_node where server_id = server_id_in );

	delete from rhn_sat_node where server_id = server_id_in;
	
	-- now get rhnServer itself.
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
show errors;

--
-- Revision 1.25  2004/11/01 17:53:03  pjones
-- bugzilla: 136124 -- Fix the "no data found" when deleting rhn_sat_cluster
--
--
--
--
-- This deletes a list of server. 
--
