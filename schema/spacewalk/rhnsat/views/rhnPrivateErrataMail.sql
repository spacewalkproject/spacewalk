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


--select count(*) from rhnMailErrataView
--where org_id = 1 and errata_id = 916;

--
-- Revision 1.2  2003/02/21 20:56:00  pjones
-- change the comments to match the code ;)
--
-- Revision 1.1  2003/02/21 20:45:00  pjones
-- private errata mail
--
-- Revision 1.4  2003/02/12 18:49:11  pjones
-- note about old errata
--
-- Revision 1.3  2002/11/14 17:20:34  pjones
-- arch -> *_arch_id and archCompat changes
--
-- Revision 1.2  2002/11/11 20:49:46  pjones
-- that line's a typo
--
-- Revision 1.1  2002/09/24 22:42:17  pjones
-- free vs paid
--
