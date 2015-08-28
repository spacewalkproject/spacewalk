DELETE FROM rhnTaskoRun
  WHERE template_id IN (
    SELECT id
      FROM rhnTaskoTemplate
      WHERE task_id IN (
        SELECT id
          FROM rhnTaskoTask
          WHERE name = 'sat-cert-check'
      )
  );

DELETE FROM rhnTaskoTemplate
  WHERE bunch_id IN (
    SELECT id
      FROM rhnTaskoBunch
      WHERE name = 'satcert-check-bunch'
  );

DELETE FROM rhnTaskoTask
  WHERE name = 'sat-cert-check';

DELETE FROM rhnTaskoSchedule
  WHERE bunch_id IN (
    SELECT id
      FROM rhnTaskoBunch
      WHERE name = 'satcert-check-bunch'
  );

DELETE FROM rhnTaskoBunch
  WHERE name = 'satcert-check-bunch';
