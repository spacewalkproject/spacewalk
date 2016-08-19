DELETE FROM rhnTaskoRun
  WHERE template_id IN (
    SELECT id
      FROM rhnTaskoTemplate
      WHERE task_id IN (
        SELECT id
          FROM rhnTaskoTask
          WHERE name = 'sync-probe-state'
      )
  );

DELETE FROM rhnTaskoTemplate
  WHERE bunch_id IN (
    SELECT id
      FROM rhnTaskoBunch
      WHERE name = 'sync-probe-bunch'
  );

DELETE FROM rhnTaskoTask
  WHERE name = 'sync-probe-state';

DELETE FROM rhnTaskoSchedule
  WHERE bunch_id IN (
    SELECT id
      FROM rhnTaskoBunch
      WHERE name = 'sync-probe-bunch'
  );

DELETE FROM rhnTaskoBunch
  WHERE name = 'sync-probe-bunch';
