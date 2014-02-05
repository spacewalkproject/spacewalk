--
-- Copyright (c) 2010--2012 Red Hat, Inc.
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


INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'daily-status-bunch', 'Sends daily report', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'sat-sync-bunch', 'Runs satellite-sync
Parameters:
- list parameter lists channels
- channel parameter specifies channel to be synced
- without parameter runs satellite-sync without parameters', 'Y');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'clear-taskologs-bunch', 'Clears taskomatic run log history
Parameters:
- days parameter specifies age of logs to be kept
- without parameter default value will be used', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'cobbler-sync-bunch', 'Applies any cobbler configuration changes', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'compare-configs-bunch', 'Schedules a comparison of config files on all systems', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'sync-probe-bunch', 'Calls the synch probe state proc', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'session-cleanup-bunch', 'Deletes expired rows from the PXTSessions table to keep it from growing too large', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'sandbox-cleanup-bunch', 'Clean up sandbox', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'repo-sync-bunch', 'Used for syncing repos to a channel', 'Y');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'package-cleanup-bunch', 'Cleans up orphaned packages', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'kickstartfile-sync-bunch', 'Syncs kickstart profiles that were generated using the wizard', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'kickstart-cleanup-bunch', 'Cleans up stale Kickstarts', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'errata-queue-bunch', 'Processes errata', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'errata-cache-bunch', 'Performs errata cache recalc for a given server or channel', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'channel-repodata-bunch', 'Generates channel repodata', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'satcert-check-bunch', 'Checks whether satellite certificate has not expired', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'cleanup-data-bunch', 'Cleans up orphaned and outdated data', null);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'reboot-action-cleanup-bunch', 'invalidate reboot actions which never finish', null);

commit;
