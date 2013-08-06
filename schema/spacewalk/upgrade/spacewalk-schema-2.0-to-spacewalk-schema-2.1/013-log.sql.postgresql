-- oracle equivalent source sha1 bb8847723477fe502d0a0c73b0224d6fd6de91cd

CREATE OR REPLACE FUNCTION log_rename_constrains()
RETURNS VOID
LANGUAGE plpgsql
AS
$$
DECLARE
    pk_constraint_name varchar;
    fk_constraint_name varchar;
BEGIN
    SELECT constraint_name INTO pk_constraint_name
    FROM information_schema.table_constraints
    WHERE table_name = 'log'
    AND constraint_type = 'PRIMARY KEY';

    SELECT constraint_name INTO fk_constraint_name
    FROM information_schema.table_constraints
    WHERE table_name = 'log'
    AND constraint_type = 'FOREIGN KEY';

    EXECUTE 'ALTER INDEX ' || pk_constraint_name || ' RENAME TO log_id_pk';

    EXECUTE 'ALTER TABLE log DROP CONSTRAINT ' || fk_constraint_name;
    EXECUTE 'ALTER TABLE log ADD CONSTRAINT log_user_id_fk FOREIGN KEY (user_id) REFERENCES web_contact_all(id)';
END;
$$;

SELECT log_rename_constrains();

DROP FUNCTION log_rename_constrains();
