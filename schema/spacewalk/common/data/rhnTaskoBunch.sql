--
-- Copyright (c) 2010 Red Hat, Inc.
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
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'daily-status-bunch', 'Sends daily report', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sat-sync', 'sat-sync description', 'Y');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'clear-tasko-log-history', 'Clears taskomatic run log history', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'cobbler-sync-bunch', 'Applies any cobbler configuration changes', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'compare-configs-bunch', 'Schedules a comparison of config files on all systems', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'clean-alerts-bunch', 'Clears current monitoring alerts', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sync-probe-bunch', 'Calls the synch probe state proc', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'session-cleanup-bunch', 'Deletes expired rows from the PXTSessions table to keep it from growing too large', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'cert-check-bunch', 'Satellite certificate check', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sandbox-cleanup-bunch', 'Clean up sandbox', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'repo-sync-bunch', 'Used for syncing repos to a channel', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'package-cleanup-bunch', 'Cleans up orphaned packages', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'kickstartfile-sync-bunch', 'Syncs kickstart profiles that were generated using the wizard', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'kickstart-cleanup-bunch', 'Cleans up stale Kickstarts', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'errata-queue-bunch', 'Processes errata', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'errata-cache-bunch', 'Performs errata cache recalc for a given server or channel', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'channel-repodata-bunch', 'Generates channel repodata', '');

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'satcert-check-bunch', 'Checks whether satellite certificate has not expired', '');

commit;
