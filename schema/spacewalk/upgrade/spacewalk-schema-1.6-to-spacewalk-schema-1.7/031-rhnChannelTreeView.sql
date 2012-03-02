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

CREATE OR REPLACE VIEW rhnChannelTreeView
(
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
	select	c.id			as id,
		1			as depth,
		c.name			as name,
		'  ' || c.name		as padded_name,
		c.channel_arch_id	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		c.label			as parent_or_self_label,
		c.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		c
	where	c.parent_channel is null
	union
	select	c.id			as id,
		2			as depth,
		c.name			as name,
		'' || c.name		as padded_name,
		c.channel_arch_id 	as channel_arch_id,
		c.last_modified		as last_modified,
		c.label			as label,
		pc.label		as parent_or_self_label,
		pc.id			as parent_or_self_id,
		c.end_of_life		as end_of_life
	from	rhnChannel		pc,
		rhnChannel		c
	where	c.parent_channel = pc.id
) S order by parent_or_self_label, parent_or_self_id;

