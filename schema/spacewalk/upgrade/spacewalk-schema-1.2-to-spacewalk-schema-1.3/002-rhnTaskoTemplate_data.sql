INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
    VALUES (sequence_nextval('rhn_tasko_template_id_seq'),
        (SELECT id FROM rhnTaskoBunch WHERE name='cleanup-data-bunch'),
        (SELECT id FROM rhnTaskoTask WHERE name='cleanup-packagechangelog-data'),
        1,
        null);
