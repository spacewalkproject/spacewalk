UPDATE rhnTaskoTemplate
SET bunch_id = (SELECT id FROM rhnTaskoBunch WHERE name='errata-cache-bunch'),
    start_if = 'FINISHED'
WHERE task_id = (SELECT id FROM rhnTaskoTask WHERE name='errata-mailer');
