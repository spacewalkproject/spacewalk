DECLARE
        type result_type is record (
                probe_id NUMBER,
                command_id NUMBER
        );
        one_row result_type;
BEGIN
FOR one_row IN (
        select probe_id, command_id from rhn_probe_param_value
                where
                        command_id in (25, 26, 27, 28, 29, 30, 31, 99, 105, 106, 107, 109, 117, 118, 123, 226, 228, 230, 249, 274, 304)
                group by probe_id, command_id
                having (probe_id, command_id) not in (
                        select probe_id, command_id from rhn_probe_param_value  where
                                command_id in (25, 26, 27, 28, 29, 30, 31, 99, 105, 106, 107, 109, 117, 118, 123, 226, 228, 230, 249, 274, 304)
                                AND param_name = 'sshbannerignore'
               )
        )
LOOP
        insert into rhn_probe_param_value
                (probe_id, command_id, param_name, value, last_update_user, last_update_date) values
                (one_row.probe_id, one_row.command_id, 'sshbannerignore', '0', 'upgrade', SYSDATE());
END LOOP;
END;
/

commit;
