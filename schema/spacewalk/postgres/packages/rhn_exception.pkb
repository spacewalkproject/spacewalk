create schema rhn_exception;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_exception,' || setting where name = 'search_path';

    CREATE OR REPLACE FUNCTION lookup_exception(exception_label_in IN VARCHAR, exception_id_out OUT NUMERIC, exception_message_out OUT VARCHAR)
    AS
    $$
    DECLARE
	exception_details CURSOR (exception_label_in VARCHAR) FOR
        SELECT id, label, message
          FROM rhnException
         WHERE label = exception_label_in;

         exc_details_rec RECORD;
		
        return_string     VARCHAR(2000);
    BEGIN
	OPEN exception_details(exception_label_in);
	LOOP
		FETCH exception_details into exc_details_rec;
		EXIT WHEN NOT FOUND;
		exception_id_out := exc_details_rec.id;
		exception_message_out := '(' || exc_details_rec.label || ')' || ' - ' || exc_details_rec.message;
		
	END LOOP;
	
        
        IF exception_message_out IS NULL
        THEN
            RAISE EXCEPTION 'EXCEPTION NOT FOUND';
        END IF;

    END;
$$
LANGUAGE PLPGSQL;


    

    CREATE OR REPLACE FUNCTION raise_exception(exception_label_in IN VARCHAR) RETURNS VOID
    AS
    $$
    DECLARE
    
        exception_id        NUMERIC;
        exception_message   VARCHAR(2000);
	exc_rec	RECORD;
        
    BEGIN
        exc_rec := lookup_exception(exception_label_in);
        
        RAISE EXCEPTION '% : % ',exc_rec.exception_id_out,exception_message_out ;--(exception_id, exception_message);

        if no_data_found then
		RAISE EXCEPTION '-20001 : Unable to lookup exception with label (%)',exception_label_in;
	end if;
        
    END;
    $$
    LANGUAGE PLPGSQL;

    create or replace function raise_exception_val(exception_label_in in varchar,val_in in numeric) returns void
    as
    $$
    declare
        exception_id        NUMERIC;
        exception_message   VARCHAR(2000);

        exc_details	RECORD;
    begin
        --exc_details := lookup_exception(exception_label_in, exception_id, exception_message);
        exc_details := lookup_exception(exception_label_in);

        
        RAISE EXCEPTION '% % (%)',exc_details.exception_id_out,exc_details.exception_message_out,val_in;
        --RAISE_APPLICATION_ERROR(exception_id, exception_message || ' (' || val_in || ')');
    if no_data_found then
	RAISE EXCEPTION '-20001, Unable to lookup exception with label (%)',exception_label_in;
        --RAISE_APPLICATION_ERROR(-20001, 'Unable to lookup exception with label (' || exception_label_in || ')');
    end if;
    end;
    $$
    language plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_exception')+1) ) where name = 'search_path';
