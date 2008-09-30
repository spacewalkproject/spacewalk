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
-- rhnActionOverview, but on a per-user basis.

-- invoke as:
--
-- select	*
-- from		rhnUserActionOverview
-- where	org_id = :oid
--		and user_id = :uid;
--

create or replace view rhnUserActionOverview as
select	ao.org_id                                       org_id,
	usp.user_id                                     user_id,
    	ao.action_id                                    id,
	ao.type_name                                    type_name,
        ao.scheduler                                    scheduler,
	ao.earliest_action                              earliest_action,
	decode(ao.name, null, ao.type_name, ao.name)	action_name,
	sa.status					action_status_id,
	astat.name                                      action_status,
	count(sa.action_id)				tally,
	ao.archived                                     archived
from	rhnActionStatus            astat,
    	rhnUserServerPerms         usp,
	rhnServerAction            sa,
	rhnActionOverview	   ao
where	ao.action_id = sa.action_id
  and   sa.server_id = usp.server_id
  and   sa.status = astat.id
group by ao.org_id,
	 usp.user_id,
	 ao.action_id,
	 ao.type_name,
	 ao.scheduler,
	 ao.earliest_action,
	 decode(ao.name, null, ao.type_name, ao.name),
	 sa.status,
	 astat.name,
	 ao.archived
order by earliest_action;

--
-- Revision 1.4  2004/07/02 19:04:11  pjones
-- bugzilla: 125937 -- this no longer uses rhnUserServerPermsDupes
--
-- Revision 1.3  2003/08/19 16:45:31  rnorwood
-- bugzilla: 97757 - actions which are not owned by the org are not selectable for archival.
--
-- Revision 1.2  2003/04/10 16:29:23  bretm
-- o  fixes and some reformatting of the rhnUserActionOverview view...
--
-- Revision 1.1  2003/04/07 17:02:24  pjones
-- bugzilla: none
--
-- a view to show an overview of actions on a per-user basis
--
