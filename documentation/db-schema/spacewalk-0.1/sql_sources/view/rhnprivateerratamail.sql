-- created by Oraschemadoc Fri Jun 13 14:06:08 2008
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "RHNSAT"."RHNPRIVATEERRATAMAIL" ("LOGIN", "LOGIN_UC", "EMAIL", "USER_ID", "SERVER_ID", "ORG_ID", "SERVER_NAME", "SERVER_ARCH", "SERVER_RELEASE", "ERRATA_ID", "ADVISORY") AS 
  with rhnSPmaxEVR as (
   select   sq2_sp.server_id, sq2_sp.name_id, max(sq2_pe.evr) max_evr
            from  rhnServerPackage  sq2_sp,
               rhnPackageEVR     sq2_pe
            where sq2_sp.evr_id = sq2_pe.id
	    group by sq2_sp.server_id, sq2_sp.name_id)
select
   w.login,
   w.login_uc,
   wpi.email,
   w.id user_id,
   s.id server_id,
   w.org_id org_id,
   s.name server_name,
   sa.name server_arch,
   s.release server_release,
   ce.errata_id errata_id,
   e.advisory
from
   rhnServer s,
   web_user_personal_info wpi,
   rhnUserInfo ui,
   rhnErrata e,
   rhnServerArch sa,
   rhnChannelErrata ce,
   web_contact w,
   rhnServerChannel sc,
   rhnServerGroupMembers sgm,
   rhnServerGroup sg
where 1=1
   and sg.id = sgm.server_group_id
   and sgm.server_id = sc.server_id
   and sg.org_id = w.org_id
   and not exists (
      select   usprefs.server_id
               from  rhnUserServerPrefs usprefs
         where 1=1
         and w.id = usprefs.user_id
               and sc.server_id = usprefs.server_id
               and usprefs.name = 'receive_notifications'
   )
   and w.id = wpi.web_user_id
   and wpi.email is not null
   and w.id = ui.user_id
      and ui.email_notify = 1
   and exists (
      select   1
      from
         rhnUserGroupType  ugt,
         rhnUserGroup      ug,
         rhnUserGroupMembers  ugm
      where 1=1
         and ugt.label = 'org_admin'
         and ugt.id = ug.group_type
         and ug.id = ugm.user_group_id
         and ugm.user_id = w.id
      union all
      select   1
      from
         rhnServerGroupMembers   sq_sgm,
         rhnUserServerGroupPerms usg
      where sc.server_id = sq_sgm.server_id
         and sq_sgm.server_group_id = usg.server_group_id
         and usg.user_id = w.id
   )
   and sc.channel_id = ce.channel_id
   and sc.server_id = s.id
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
         and sc.channel_id = cp.channel_id
         and cp.package_id = p.id
         and ce.errata_id = ep.errata_id
         and ep.package_id = p.id
         and sc.channel_id = ce.channel_id
         and ce.errata_id = ep.errata_id
         and sc.server_id = sp.server_id
         and sp.name_id = p.name_id
         and sp.evr_id = sp_evr.id
         and p.evr_id = p_evr.id
         and sp.evr_id != p.evr_id
         and sp_evr.evr < p_evr.evr
         and sp_evr.evr = (
            select max_evr from rhnSPmaxEVR rsme
	    where sp.server_id = rsme.server_id
               and sp.name_id = rsme.name_id
         )
         and p.package_arch_id = spac.package_arch_id
         and s.server_arch_id = spac.server_arch_id
   )
   and s.server_arch_id = sa.id
   and ce.errata_id = e.id
   and not exists ( select 1
                      from rhnWebContactDisabled wcd
                     where wcd.id = w.id )
 
/
