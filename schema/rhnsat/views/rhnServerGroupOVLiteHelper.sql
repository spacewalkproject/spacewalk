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
-- $Id$
--
-- this is a helper for rhnServerGroupOverviewLite and it's Vis brother.

create or replace view
rhnServerGroupOVLiteHelper as
select	sgm.server_group_id						server_group_id,
		e.advisory_type							advisory_type
from	rhnErrata								e,
		rhnServerNeededPackageCache				snpc,
		rhnServerGroupMembers					sgm
where   1=1
	and sgm.server_id = snpc.server_id
	and snpc.errata_id = e.id
/

-- $Log$
-- Revision 1.1  2002/11/11 23:37:43  pjones
-- add a Vis varient
--
