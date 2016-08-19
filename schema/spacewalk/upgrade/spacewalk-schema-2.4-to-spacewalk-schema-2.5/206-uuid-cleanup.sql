INSERT INTO rhnTaskoBunch (id, name, description, org_bunch)
    select sequence_nextval('rhn_tasko_bunch_id_seq'), 'uuid-cleanup-bunch', 'purge orphaned uuid records', null from dual
        where not exists (select 1 from rhnTaskoBunch where name = 'uuid-cleanup-bunch');

-- Every hour

INSERT INTO rhnTaskoSchedule (id, job_label, bunch_id, active_from, cron_expr)
    select sequence_nextval('rhn_tasko_schedule_id_seq'), 'uuid-cleanup-default',
        (SELECT id FROM rhnTaskoBunch WHERE name='uuid-cleanup-bunch'),
        current_timestamp, '0 0 * * * ?' from dual
        where not exists (select 1 from rhnTaskoSchedule where job_label = 'uuid-cleanup-default');

INSERT INTO rhnTaskoTask (id, name, class)
    select sequence_nextval('rhn_tasko_task_id_seq'), 'uuid-cleanup', 'com.redhat.rhn.taskomatic.task.UuidCleanup' from dual
where not exists (select 1 from rhnTaskoTask where name = 'uuid-cleanup');

INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
    select sequence_nextval('rhn_tasko_template_id_seq'),
            (SELECT id FROM rhnTaskoBunch WHERE name='uuid-cleanup-bunch'),
            (SELECT id FROM rhnTaskoTask WHERE name='uuid-cleanup'),
            0,
            null from dual
        where not exists (select 1 from rhnTaskoTemplate where bunch_id = (SELECT id FROM rhnTaskoBunch WHERE name='uuid-cleanup-bunch'));
