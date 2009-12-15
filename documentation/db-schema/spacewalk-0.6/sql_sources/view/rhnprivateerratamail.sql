-- created by Oraschemadoc Mon Aug 31 10:54:32 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNPRIVATEERRATAMAIL" ("USER_ID", "SERVER_ID", "ORG_ID", "CHANNEL_ID", "ERRATA_ID") AS 
  select
   w.id user_id,
   s.id server_id,
   w.org_id org_id,
   sc.channel_id channel_id,
   ce.errata_id errata_id
from
   rhnServer s,
   web_user_personal_info wpi,
   rhnUserInfo ui,
   rhnChannelErrata ce,
   web_contact w,
   rhnServerChannel sc,
   rhnUserServerPerms usp
where
   -- we plan on starting with org_id, and server group is the
   -- best place to find that that's near servers
   -- filter out servers that aren't in useful channels
   sc.channel_id = ce.channel_id
   -- find the server, so we can do s.arch comparisons
   and sc.server_id = s.id
   -- filter out users who don't want/can't get email
   and w.id = wpi.web_user_id
   and wpi.email is not null
   and w.id = ui.user_id
   and s.id = usp.server_id
   and usp.user_id = w.id
   -- filter out users who don't want mail about this server
   -- they get an entry if they _don't_ want mail
   and not exists (
      select   usprefs.server_id
               from  rhnUserServerPrefs usprefs
         where w.id = usprefs.user_id
               and sc.server_id = usprefs.server_id
               and usprefs.name = 'receive_notifications'
   )
   and ui.email_notify = 1
      -- check permissions. For this query being an org admin is the
      -- most common thing, so we test for that first
   and exists (
         select 1
      from
            rhnPackageEVR        p_evr,
            rhnPackageEVR        sp_evr,
            rhnServerPackage     sp,
            rhnChannelPackage    cp,
            rhnPackage        p,
            rhnErrataPackage     ep,
            rhnServerPackageArchCompat spac
      where 1=1
         -- packages from channels this server is subscribed to
         and sc.channel_id = cp.channel_id
         and cp.package_id = p.id
         -- part of an errata
         and ce.errata_id = ep.errata_id
         and ep.package_id = p.id
         -- and that errata maps back to the server channel
         and sc.channel_id = ce.channel_id
         and ce.errata_id = ep.errata_id
         -- also installed on this server
         and sc.server_id = sp.server_id
         and sp.name_id = p.name_id
         and sp.evr_id = sp_evr.id
         -- different evr
         and p.evr_id = p_evr.id
         and sp.evr_id != p.evr_id
         -- and newer evr
         and sp_evr.evr < p_evr.evr
         and sp_evr.evr = (
            select max(sq2_pe.evr) max_evr
                from  rhnServerPackage  sq2_sp,
                rhnPackageEVR     sq2_pe
                where sq2_sp.evr_id = sq2_pe.id and
                  sq2_sp.server_id = sp.server_id and
                  sp.name_id = sq2_sp.name_id
	            group by sq2_sp.server_id, sq2_sp.name_id
         )
         -- compat arch
         and p.package_arch_id = spac.package_arch_id
         and s.server_arch_id = spac.server_arch_id
   )
   and not exists ( select 1
                      from rhnWebContactDisabled wcd
                     where wcd.id = w.id )

 
/
