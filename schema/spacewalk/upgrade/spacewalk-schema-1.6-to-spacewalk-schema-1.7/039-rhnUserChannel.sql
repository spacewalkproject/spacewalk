--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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
--

create or replace view rhnUserChannel
as
select
   cfp.user_id,
   cfp.org_id,
   cfm.channel_id,
   'manage' as role
from rhnChannelFamilyMembers cfm,
      rhnUserChannelFamilyPerms cfp
where
   cfp.channel_family_id = cfm.channel_family_id and
   rhn_channel.user_role_check(cfm.channel_id, cfp.user_id, 'manage') = 1
union all
select
   cfp.user_id,
   cfp.org_id,
   cfm.channel_id,
   'subscribe' as role
from rhnChannelFamilyMembers cfm,
      rhnUserChannelFamilyPerms cfp
where
   cfp.channel_family_id = cfm.channel_family_id and
   rhn_channel.user_role_check(cfm.channel_id, cfp.user_id, 'subscribe') = 1
union all
select
   w.id as user_id,
   w.org_id,
   s.id as channel_id,
   'subscribe' as role
from rhnSharedChannelView s,
      web_contact w
where
   w.org_id = s.org_trust_id and
   rhn_channel.user_role_check(s.id, w.id, 'subscribe') = 1;

