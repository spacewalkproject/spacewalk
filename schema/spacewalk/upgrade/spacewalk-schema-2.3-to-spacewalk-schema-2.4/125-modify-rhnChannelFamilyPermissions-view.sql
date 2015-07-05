--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

drop view rhnChannelFamilyPermissions;

create or replace view rhnChannelFamilyPermissions as
	select	channel_family_id,
		to_number(null, null) as org_id,
		created,
		modified
	from	rhnPublicChannelFamily
	union
	select	channel_family_id,
		org_id,
		created,
		modified
	from	rhnPrivateChannelFamily;

