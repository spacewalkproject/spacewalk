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

create table 
rhnTaskQueue
(
	org_id		numeric not null
			constraint rhn_task_queue_org_id_fk
				references web_customer(id)
				on delete cascade,
	task_name	VARCHAR(64) not null,
	task_data	numeric,
	priority	numeric default 0,
	earliest	timestamp default (current_timestamp) not null
);

create index rhn_task_queue_org_task_idx
	on rhnTaskQueue(org_id, task_name);
--	tablespace [[64k_tbs]]


create index rhn_task_queue_earliest
	on rhnTaskQueue(earliest);
--        tablespace [[64k_tbs]]


--
-- Revision 1.8  2004/02/16 19:31:41  cturner
-- index for don to fix high io on rhnTaskQueue
--
-- Revision 1.7  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/05/27 03:24:47  cturner
-- new column for task queue
--
-- Revision 1.4  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
