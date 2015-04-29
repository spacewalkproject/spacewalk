INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
             VALUES (sequence_nextval('rhn_tasko_bunch_id_seq'), 'auto-errata-bunch', 'Schedule automatic errata update actions', null);


INSERT INTO rhnTaskoSchedule (id, job_label, bunch_id, active_from, cron_expr)
    VALUES(sequence_nextval('rhn_tasko_schedule_id_seq'), 'auto-errata-default',
        (SELECT id FROM rhnTaskoBunch WHERE name='auto-errata-bunch'),
        current_timestamp, '0 5/10 * * * ?');

INSERT INTO rhnTaskoTask (id, name, class)
         VALUES (sequence_nextval('rhn_tasko_task_id_seq'), 'auto-errata', 'com.redhat.rhn.taskomatic.task.AutoErrataTask');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (sequence_nextval('rhn_tasko_template_id_seq'),
                        (SELECT id FROM rhnTaskoBunch WHERE name='auto-errata-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='auto-errata'),
                        0,
                        null);
