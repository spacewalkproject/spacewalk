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
select	ao.org_id                                       as org_id,
	usp.user_id                                     as user_id,
    	ao.action_id                                    as id,
	ao.type_name                                    as type_name,
        ao.scheduler                                    as scheduler,
	ao.earliest_action                              as earliest_action,
	coalesce( ao.name, ao.type_name )		as action_name,
	sa.status					as action_status_id,
	astat.name                                      as action_status,
	count(sa.action_id)				as tally,
	ao.archived                                     as archived
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
	 coalesce( ao.name, ao.type_name ),
	 sa.status,
	 astat.name,
	 ao.archived
order by earliest_action;

