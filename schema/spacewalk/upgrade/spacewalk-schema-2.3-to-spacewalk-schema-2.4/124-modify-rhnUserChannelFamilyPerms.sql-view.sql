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

drop view rhnUserChannel;
drop view rhnUserChannelTreeView;
drop view rhnUserChannelFamilyPerms;

create or replace view rhnUserChannelFamilyPerms as
	select	pcf.channel_family_id,
		u.org_id as org_id,
		u.id as user_id,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	pcf.channel_family_id,
		u.org_id,
		u.id as user_id,
		pcf.created,
		pcf.modified
	from	rhnPrivateChannelFamily pcf,
		web_contact u
	where	u.org_id = pcf.org_id;

CREATE OR REPLACE VIEW rhnUserChannelTreeView
(
        user_id,
        org_id,
        id,
        depth,
        name,
        padded_name,
        channel_arch_id,
        last_modified,
        label,
        parent_or_self_label,
        parent_or_self_id,
        end_of_life
)
AS
select * from (
        select  cfp.user_id             as user_id,
                cfp.org_id              as org_id,
                c.id                    as id,
                1                       as depth,
                c.name                  as name,
                '  ' || c.name          as padded_name,
                c.channel_arch_id       as channel_arch_id,
                c.last_modified         as last_modified,
                c.label                 as label,
                c.label                 as parent_or_self_label,
                c.id                    as parent_or_self_id,
                c.end_of_life           as end_of_life
        from    rhnChannel              c,
                rhnChannelFamilyMembers cfm,
                rhnUserChannelFamilyPerms cfp
        where   cfp.channel_family_id = cfm.channel_family_id
                and cfm.channel_id = c.id
                and c.parent_channel is null
        union
        select  cfp.user_id             as user_id,
                cfp.org_id              as org_id,
                c.id                    as id,
                2                       as depth,
                c.name                  as name,
                '' || c.name            as padded_name,
                c.channel_arch_id       as channel_arch_id,
                c.last_modified         as last_modified,
                c.label                 as label,
                pc.label                as parent_or_self_label,
                pc.id                   as parent_or_self_id,
                c.end_of_life           as end_of_life
        from    rhnChannel              pc,
                rhnChannel              c,
                rhnChannelFamilyMembers cfm,
                rhnUserChannelFamilyPerms cfp
        where   cfp.channel_family_id = cfm.channel_family_id
                and cfm.channel_id = c.id
                and c.parent_channel = pc.id
) S order by parent_or_self_label, parent_or_self_id;

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

