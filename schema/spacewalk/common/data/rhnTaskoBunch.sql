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


INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'daily-status-bunch', 'Sends daily report', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sat-sync', 'sat-sync description', 'Y', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'clear-tasko-log-history', 'Clears taskomatic run log history', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'cobbler-sync-bunch', 'Applies any cobbler configuration changes', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'compare-configs-bunch', 'Schedules a comparison of config files on all systems', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'clean-alerts-bunch', 'Clears current monitoring alerts', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sync-probe-bunch', 'Calls the synch probe state proc', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'session-cleanup-bunch', 'Deletes expired rows from the PXTSessions table to keep it from growing too large', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'cert-check-bunch', 'Satellite certificate check', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'sandbox-cleanup-bunch', 'Clean up sandbox', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'repo-sync-bunch', 'Used for syncing repos to a channel', '', sysdate);

INSERT INTO rhnTaskoBunch (id, name, description, org_bunch, active_from)
             VALUES (rhn_tasko_bunch_id_seq.nextval, 'package-cleanup-bunch', 'Cleans up orphaned packages', '', sysdate);

commit;
