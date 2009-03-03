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
-- This view is used for extracting data needed by the errata mailer
-- for private errata mails
--
--

create or replace view
rhnPrivateErrataMail
as
select
   w.login, 
   w.login_uc,
   wpi.email,  
   w.id as user_id,
   s.id as server_id,
   -- use sg here so we can start with org and work to errata from there
   w.org_id as org_id,
   s.name as server_name,
   sa.name as server_arch,
   s.release as server_release,
   ce.errata_id as errata_id,
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
   -- we plan on starting with org_id, and server group is the 
   -- best place to find that that's near servers
   and sg.id = sgm.server_group_id
   and sgm.server_id = sc.server_id
   -- then find the contacts, because permission checking is next
   and sg.org_id = w.org_id
   -- filter out users who don't want mail about this server
   -- they get an entry if they _don't_ want mail
   and not exists (
      select   usprefs.server_id 
               from  rhnUserServerPrefs usprefs
         where 1=1
         and w.id = usprefs.user_id 
               and sc.server_id = usprefs.server_id 
               and usprefs.name = 'receive_notifications'
   )
   -- filter out users who don't want/can't get email
   and w.id = wpi.web_user_id
   and wpi.email is not null
   and w.id = ui.user_id
      and ui.email_notify = 1
      -- check permissions. For this query being an org admin is the
      -- most common thing, so we test for that first
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
   -- filter out servers that aren't in useful channels
   and sc.channel_id = ce.channel_id
   -- find the server, so we can do s.arch comparisons
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
            select max_evr from (select sq2_sp.server_id,
					 sq2_sp.name_id,
					 max(sq2_pe.evr) as max_evr
                                 from  rhnServerPackage  sq2_sp,
                                       rhnPackageEVR     sq2_pe
                                 where sq2_sp.evr_id = sq2_pe.id
                                 group by sq2_sp.server_id, sq2_sp.name_id) rsme
	    where sp.server_id = rsme.server_id
               and sp.name_id = rsme.name_id
         )
         -- compat arch
         and p.package_arch_id = spac.package_arch_id
         and s.server_arch_id = spac.server_arch_id
   )
   -- below here isn't needed except for output
   and s.server_arch_id = sa.id
   and ce.errata_id = e.id
   and not exists ( select 1
                      from rhnWebContactDisabled wcd
                     where wcd.id = w.id )
;

