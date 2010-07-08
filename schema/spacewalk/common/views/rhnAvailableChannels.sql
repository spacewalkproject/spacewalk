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
-- tricky view.  it explodes to a full cartesian product when
-- not queried via org_id, so DO NOT DO THAT :)

create or replace view
rhnAvailableChannels
(
    	org_id,
	channel_id,
	channel_depth,
	channel_name,
	channel_arch_id,
	padded_name,
	current_members,
	available_members,
        last_modified,
        channel_label,
	parent_or_self_label,
	parent_or_self_id 
)
as
select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
    (SELECT COUNT(1)
     FROM rhnServer S 
     INNER JOIN rhnServerChannel SC
       ON SC.server_id = S.id
     WHERE SC.channel_id = CT.id AND
           S.org_id = CT.org_id),
     rhn_channel.available_chan_subscriptions(ct.id, ct.org_id),
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnOrgChannelTreeView CT
UNION ALL
select
     ct.org_id,
     ct.id,
     CT.depth,
     CT.name,
     CT.channel_arch_id,
     CT.padded_name,
    (SELECT COUNT(1)
     FROM rhnServer S 
     INNER JOIN rhnServerChannel SC
       ON SC.server_id = S.id
     WHERE SC.channel_id = CT.id AND
           S.org_id = CT.org_id),
     NULL,
     CT.last_modified,
     CT.label,
     CT.parent_or_self_label,
     CT.parent_or_self_id
from
     rhnSharedChannelTreeView CT
;

