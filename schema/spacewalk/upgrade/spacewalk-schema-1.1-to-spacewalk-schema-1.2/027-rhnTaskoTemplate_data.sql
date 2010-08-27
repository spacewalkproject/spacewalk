INSERT INTO rhnTaskoTemplate (id, bunch_id, task_id, ordering, start_if)
             VALUES (rhn_tasko_template_id_seq.nextval,
                        (SELECT id FROM rhnTaskoBunch WHERE name='errata-cache-bunch'),
                        (SELECT id FROM rhnTaskoTask WHERE name='errata-cache'),
                        0,
                        '');
