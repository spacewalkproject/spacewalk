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
	  web_contact U,
	  rhnActionType AT,
	  rhnAction A
WHERE	  A.scheduler = U.id(+)
AND	  A.action_type = AT.id
ORDER BY  A.earliest_action;

--
-- Revision 1.13  2003/08/19 16:45:31  rnorwood
-- bugzilla: 97757 - actions which are not owned by the org are not selectable for archival.
--
-- Revision 1.12  2003/03/17 01:43:59  cturner
-- more schema for autoupdating
--
-- Revision 1.11  2001/09/20 19:24:54  cturner
-- removing redundant / when semicolon was added
--
-- Revision 1.10  2001/09/20 19:15:29  dsmith
-- Added final semicolon.
--
-- Revision 1.9  2001/08/08 21:29:52  cturner
-- action changes
--
-- Revision 1.8  2001/07/17 20:28:27  cturner
-- added nullable, meaningless name column to rhnAction so people can name their action
--
-- Revision 1.7  2001/07/13 19:23:50  cturner
-- archived server action db layer
--
-- Revision 1.6  2001/07/04 20:11:29  cturner
-- fix errata populate script, plus a possibly questionable improvement to the action overview view
--
-- Revision 1.5  2001/06/29 08:30:53  cturner
-- more underscore changes, plus switching from rhnUser to web_contact.  may switch back later, but avoiding synonyms and such seems to make things cleaner
--
-- Revision 1.4  2001/06/28 20:31:17  cturner
-- made the view make more sense.  arithmetic is good.
--
-- Revision 1.3  2001/06/27 02:03:57  gafton
-- Add Log
--
