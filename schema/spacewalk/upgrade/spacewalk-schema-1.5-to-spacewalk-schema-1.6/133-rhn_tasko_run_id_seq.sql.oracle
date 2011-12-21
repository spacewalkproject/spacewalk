BEGIN
   DECLARE
      seq_template_number NUMBER;
      seq_run_number NUMBER;
   BEGIN

        EXECUTE IMMEDIATE
            'SELECT rhn_tasko_template_id_seq.nextval FROM dual'
        INTO seq_template_number;

        EXECUTE IMMEDIATE
            'SELECT rhn_tasko_run_id_seq.nextval FROM dual'
        INTO seq_run_number;

        IF (seq_template_number != seq_run_number) THEN
            EXECUTE IMMEDIATE
                'ALTER SEQUENCE rhn_tasko_run_id_seq INCREMENT BY ' || (seq_template_number - seq_run_number);

            EXECUTE IMMEDIATE
                'SELECT rhn_tasko_run_id_seq.nextval FROM dual'
            INTO seq_run_number;

            EXECUTE IMMEDIATE
                'ALTER SEQUENCE rhn_tasko_run_id_seq INCREMENT BY 1';
        END IF;

    END;
END;
/
