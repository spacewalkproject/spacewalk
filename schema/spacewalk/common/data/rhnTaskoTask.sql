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


INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'repo-sync', 'com.redhat.rhn.taskomatic.task.RepoSyncTask')

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'satellite-sync', 'com.redhat.rhn.taskomatic.task.SatSyncTask')

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'kickstartfile-sync', 'com.redhat.rhn.taskomatic.task.KickstartFileSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'kickstart-cleanup', 'com.redhat.rhn.taskomatic.task.KickstartCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'errata-cache', 'com.redhat.rhn.taskomatic.task.ErrataCacheTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'errata-queue', 'com.redhat.rhn.taskomatic.task.ErrataQueue');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'errata-mailer', 'com.redhat.rhn.taskomatic.task.ErrataMailer');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'sandbox-cleanup', 'com.redhat.rhn.taskomatic.task.SandboxCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'session-cleanup', 'com.redhat.rhn.taskomatic.task.SessionCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'channel-repodata', 'com.redhat.rhn.taskomatic.task.ChannelRepodata')

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'package-cleanup', 'com.redhat.rhn.taskomatic.task.PackageCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'cobbler-sync', 'com.redhat.rhn.taskomatic.task.CobblerSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'daily-summary', 'com.redhat.rhn.taskomatic.task.DailySummary');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'summary-population', 'com.redhat.rhn.taskomatic.task.SummaryPopulation');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'compare-config-files', 'com.redhat.rhn.taskomatic.task.CompareConfigFilesTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'clean-current-alerts', 'com.redhat.rhn.taskomatic.task.CleanCurrentAlerts');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'sync-probe-state', 'com.redhat.rhn.taskomatic.task.SynchProbeState');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (rhn_tasko_task_id_seq.nextval, 'sat-cert-check', 'com.redhat.rhn.taskomatic.task.SatelliteCertificateCheck');

commit;
