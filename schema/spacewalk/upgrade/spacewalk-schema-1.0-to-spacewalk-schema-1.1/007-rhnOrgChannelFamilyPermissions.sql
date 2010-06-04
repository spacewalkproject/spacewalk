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
		u.org_id org_id,
		to_number(null) max_members,
		0 current_members,
		to_number(null) fve_max_members,
		0 fve_current_members,
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

--
--
-- Revision 1.2  2004/04/16 16:07:12  pjones
-- bugzilla: none -- 8.1.7 won't let you use "null foo" as a column in a view
-- that gets unioned with a typed column.  you have to use "to_number(null) foo".  What a load of crap.
--
-- Revision 1.1  2004/04/14 00:09:24  pjones
-- bugzilla: 120761 -- split rhnChannelPermissions into two tables, eliminating
-- a frequent full table scan
--
