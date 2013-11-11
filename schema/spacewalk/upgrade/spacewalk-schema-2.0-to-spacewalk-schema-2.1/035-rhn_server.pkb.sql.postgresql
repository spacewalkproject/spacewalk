-- oracle equivalent source sha1 4654e8979a0e16254c65bbc25229624c52de426c


update pg_settings set setting = 'rhn_server,' || setting where name = 'search_path';

    create or replace function update_needed_cache(
        server_id_in in numeric
	) returns void as $$
    begin
      delete from rhnServerNeededCache
        where server_id = server_id_in;
      insert into rhnServerNeededCache
             (server_id, errata_id, package_id, channel_id)
        (select distinct sp.server_id, x.errata_id, p.id, x.channel_id
           FROM (SELECT sp_sp.server_id, sp_sp.name_id,
		        sp_sp.package_arch_id, max(sp_pe.evr) AS max_evr
                   FROM rhnServerPackage sp_sp
                   join rhnPackageEvr sp_pe ON sp_pe.id = sp_sp.evr_id
                  GROUP BY sp_sp.server_id, sp_sp.name_id, sp_sp.package_arch_id) sp
           join rhnPackage p ON p.name_id = sp.name_id
           join rhnPackageEvr pe ON pe.id = p.evr_id AND sp.max_evr < pe.evr
           join rhnPackageUpgradeArchCompat puac
	            ON puac.package_arch_id = sp.package_arch_id
		    AND puac.package_upgrade_arch_id = p.package_arch_id
           join rhnServerChannel sc ON sc.server_id = sp.server_id
           join rhnChannelPackage cp ON cp.package_id = p.id
	            AND cp.channel_id = sc.channel_id
           left join (SELECT ep.errata_id, ce.channel_id, ep.package_id
                        FROM rhnChannelErrata ce
                        join rhnErrataPackage ep
			         ON ep.errata_id = ce.errata_id
			join rhnServerChannel sc_sc
			         ON sc_sc.channel_id = ce.channel_id
		       WHERE sc_sc.server_id = server_id_in) x
             ON x.channel_id = sc.channel_id AND x.package_id = cp.package_id
          where sp.server_id = server_id_in);
	end$$ language plpgsql;

-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_server')+1) ) where name = 'search_path';
