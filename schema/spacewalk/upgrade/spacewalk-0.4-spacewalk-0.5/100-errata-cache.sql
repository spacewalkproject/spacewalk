

drop index rhn_snec_eid_sid_idx;
drop index rhn_snec_sid_eid_idx;
drop index rhn_snec_oid_eid_sid_idx;
drop table rhnServerNeededErrataCache;


/* Remove org id, we don't need it */
ALTER TABLE rhnServerNeededPackageCache DROP CONSTRAINT rhn_sncp_oid_nn;
ALTER TABLE rhnServerNeededPackageCache DROP CONSTRAINT rhn_sncp_oid_fk;
drop index rhn_snpc_oid_idx;
alter table  rhnServerNeededPackageCache drop column  org_id;

/* drop old indexes */
drop index rhn_snpc_pid_idx;
drop index rhn_snpc_sid_idx;
drop index rhn_snpc_eid_idx;


/* rename table */
alter table
   rhnServerNeededPackageCache
  rename to
   rhnServerNeededCache;


/*create new indexes */
create index rhn_snc_pid_idx
        on rhnServerNeededCache(package_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;

create index rhn_snc_sid_idx
        on rhnServerNeededCache(server_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;

create index rhn_snc_eid_idx
        on rhnServerNeededCache(errata_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;


create index rhn_snc_speid_idx
        on rhnServerNeededCache(server_id, package_id, errata_id)
        parallel
        tablespace [[128m_tbs]]
        nologging;



create or replace view
rhnServerNeededPackageCache
(
    server_id,
    package_id,
    errata_id
)
as
select
        server_id, 
        package_id,
        max(errata_id) as errata_id
        from rhnServerNeededCache 
        group by server_id, package_id;


create or replace view
rhnServerNeededErrataCache
(
    server_id,
    errata_id
)
as
select
   distinct  server_id, errata_id
   from rhnServerNeededCache;





CREATE OR REPLACE VIEW
rhnServerNeededView
(
    org_id,
    server_id,
    errata_id,
    package_id,
    package_name_id
)
AS
SELECT   distinct  S.org_id,
         S.id,
         PE.errata_id,
         P.id,
         P.name_id
FROM
         rhnPackage P,
         rhnServerPackageArchCompat SPAC,
         rhnPackageEVR P_EVR,
         rhnPackageEVR SP_EVR,
         rhnServerPackage SP,
         rhnChannelPackage CP,
         rhnServerChannel SC,
         rhnServer S,
         rhnErrataPackage PE,
         rhnChannelErrata EC
WHERE
         SC.server_id = S.id
  AND    SC.channel_id = CP.channel_id
  AND    CP.package_id = P.id
  AND    PE.package_id = P.id (+)
  AND    PE.errata_id = EC.errata_id (+)
  AND    EC.channel_id = SC.channel_id (+)
  AND    p.package_arch_id = spac.package_arch_id
  AND    spac.server_arch_id = s.server_arch_id
  AND    SP_EVR.id = SP.evr_id
  AND    P_EVR.id = P.evr_id
  AND    SP.server_id = S.id
  AND    SP.name_id = P.name_id
  AND    SP.evr_id != P.evr_id
  AND    SP_EVR.evr < P_EVR.evr
  AND    SP_EVR.evr = (SELECT MAX(PE.evr) FROM rhnServerPackage SP2, rhnPackageEvr PE WHERE PE.id = SP2.evr_id AND SP2.server_id = SP.server_id AND SP2.name_id = SP.name_id);



CREATE OR REPLACE VIEW rhnServerErrataTypeView
(
        server_id,
        errata_id,
        errata_type
)
AS
SELECT
        SNEC.server_id,
        SNEC.errata_id,
        E.advisory_type
FROM    rhnErrata E,
        rhnServerNeededErrataCache SNEC
WHERE   E.id = SNEC.errata_id
GROUP BY SNEC.server_id, SNEC.errata_id, E.advisory_type;


CREATE OR REPLACE PROCEDURE
queue_server(server_id_in IN NUMBER, immediate_in IN NUMBER := 1)
IS
    org_id_tmp NUMBER;
BEGIN
    IF immediate_in > 0
    THEN
        DELETE FROM rhnServerNeededCache WHERE server_id = server_id_in;
        INSERT INTO rhnServerNeededCache
            (SELECT server_id, errata_id, package_id
               FROM rhnServerNeededView
              WHERE server_id = server_id_in);

    ELSE
          SELECT org_id INTO org_id_tmp FROM rhnServer WHERE id = server_id_in;

          INSERT
            INTO rhnTaskQueue
                 (org_id, task_name, task_data)
          VALUES (org_id_tmp,
                  'update_server_errata_cache',
                  server_id_in);
    END IF;
END queue_server;

/

create or replace procedure
delete_errata (
        errata_id_in in number
) is
begin
        delete from rhnServerNeededCache where errata_id = errata_id_in;
        delete from rhnPaidErrataTempCache where errata_id = errata_id_in;
        delete from rhnErrataFile where errata_id = errata_id_in;
        delete from rhnErrataPackage where errata_id = errata_id_in;
        delete from rhnErrata where id = errata_id_in;
        delete from rhnErrataTmp where id = errata_id_in;
end delete_errata;
/

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
	update rhnKickstartSession
		set old_server_id = case when old_server_id = server_id_in then null else old_server_id end,
		    new_server_id = case when new_server_id = server_id_in then null else new_server_id end
		where old_server_id = server_id_in 
		   or new_server_id = server_id_in;

	rhn_channel.clear_subscriptions(server_id_in,1);
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
	delete from rhnChannelFamilyLicenseConsent where server_id = server_id_in;
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
