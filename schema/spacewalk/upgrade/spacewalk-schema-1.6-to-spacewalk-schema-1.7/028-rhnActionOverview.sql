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
CREATE OR REPLACE VIEW
rhnActionOverview
(
	org_id,
	action_id,
	type_id,
	type_name,
	name,
    	scheduler,
	scheduler_login,
	earliest_action,
	total_count,
	successful_count,
	failed_count,
	in_progress_count,
	archived
)
AS
SELECT    A.org_id,
	  A.id,
	  AT.id,
	  AT.name,
	  A.name,
	  A.scheduler,
	  U.login,
	  A.earliest_action,
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id),
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 2), -- XXX: don''t hard code status here :)
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status = 3),
	  (SELECT COUNT(*) FROM rhnServerAction WHERE action_id = A.id AND status NOT IN (2, 3)),
	  A.archived
FROM
	  rhnActionType AT,
	  rhnAction A
		left outer join
          web_contact U
		on A.scheduler = U.id
WHERE A.action_type = AT.id
ORDER BY  A.earliest_action;

