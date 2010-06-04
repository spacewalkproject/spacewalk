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
--

create or replace view rhnOrgChannelFamilyPermissions as
	select	pcf.channel_family_id,
		u.org_id as org_id,
		to_number(null, null) as max_members,
		0 as current_members,
		to_number(null, null) as fve_max_members,
		0 as fve_current_members,
		pcf.created,
		pcf.modified
	from	rhnPublicChannelFamily pcf,
		web_contact u
	union
	select	channel_family_id,
		org_id,
		max_members,
		current_members,
		fve_max_members,
		fve_current_members,
		created,
		modified
	from	rhnPrivateChannelFamily;

