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

create or replace view rhnUserChannelFamilyPerms as
	select	pcf.channel_family_id,
		u.org_id as org_id,
		u.id as user_id,
		to_number(null, null) as max_members,
		0 as current_members,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	pcf.channel_family_id,
		u.org_id,
		u.id as user_id,
		pcf.max_members,
		pcf.current_members,
		pcf.created,
		pcf.modified
	from	rhnPrivateChannelFamily pcf,
		web_contact u
	where	u.org_id = pcf.org_id;

