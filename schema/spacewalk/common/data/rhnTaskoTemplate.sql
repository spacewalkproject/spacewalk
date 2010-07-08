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


INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='daily-status-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='summary-population'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                         (SELECT id FROM rhnTaskoBunch WHERE name='daily-status-bunch'),
                         (SELECT id FROM rhnTaskoTask WHERE name='daily-summary'),
                         1,
                         'FINISHED');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='sat-sync'),
                        (SELECT id FROM rhnTaskoTask WHERE name='satellite-sync'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='clear-tasko-log-history'),
                        (SELECT id FROM rhnTaskoTask WHERE name='clear-log-history'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='cobbler-sync-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='cobbler-sync'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='compare-configs-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='compare-config-files'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='clean-alerts-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='clean-current-alerts'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='sync-probe-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='sync-probe-state'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='session-cleanup-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='session-cleanup'),
                        0,
                        '');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='cert-check-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='sat-cert-check'),
                        0,
                        '');

commit;
