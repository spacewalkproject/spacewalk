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


INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'repo-sync', 'com.redhat.rhn.taskomatic.task.RepoSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'satellite-sync', 'com.redhat.rhn.taskomatic.task.SatSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'kickstartfile-sync', 'com.redhat.rhn.taskomatic.task.KickstartFileSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'kickstart-cleanup', 'com.redhat.rhn.taskomatic.task.KickstartCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'errata-cache', 'com.redhat.rhn.taskomatic.task.ErrataCacheTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'errata-queue', 'com.redhat.rhn.taskomatic.task.ErrataQueue');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'errata-mailer', 'com.redhat.rhn.taskomatic.task.ErrataMailer');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'sandbox-cleanup', 'com.redhat.rhn.taskomatic.task.SandboxCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'session-cleanup', 'com.redhat.rhn.taskomatic.task.SessionCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'channel-repodata', 'com.redhat.rhn.taskomatic.task.ChannelRepodata');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'package-cleanup', 'com.redhat.rhn.taskomatic.task.PackageCleanup');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'cobbler-sync', 'com.redhat.rhn.taskomatic.task.CobblerSyncTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'daily-summary', 'com.redhat.rhn.taskomatic.task.DailySummary');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'summary-population', 'com.redhat.rhn.taskomatic.task.SummaryPopulation');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'compare-config-files', 'com.redhat.rhn.taskomatic.task.CompareConfigFilesTask');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'sync-probe-state', 'com.redhat.rhn.taskomatic.task.SynchProbeState');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'sat-cert-check', 'com.redhat.rhn.taskomatic.task.SatelliteCertificateCheck');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'clear-log-history', 'com.redhat.rhn.taskomatic.task.ClearLogHistory');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'cleanup-timeseries-data', 'com.redhat.rhn.taskomatic.task.TimeSeriesCleanUp');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'cleanup-packagechangelog-data', 'com.redhat.rhn.taskomatic.task.ChangeLogCleanUp');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'reboot-action-cleanup', 'com.redhat.rhn.taskomatic.task.RebootActionCleanup');

commit;
