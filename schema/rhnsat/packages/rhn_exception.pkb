--
-- $Id$
--

CREATE OR REPLACE
PACKAGE BODY rhn_exception
IS

    PROCEDURE lookup_exception(exception_label_in IN VARCHAR2, exception_id_out OUT NUMBER, exception_message_out OUT VARCHAR2)
    IS
        return_string     VARCHAR2(2000);
    BEGIN
        FOR exc IN exception_details(exception_label_in)
        LOOP
            exception_id_out := exc.id;
            exception_message_out := '(' || exc.label || ')' || ' - ' || exc.message;
        END LOOP exception_details;

        IF exception_message_out IS NULL
        THEN
            RAISE NO_DATA_FOUND;
        END IF;

    END lookup_exception;
    
    PROCEDURE raise_exception(exception_label_in IN VARCHAR2)
    IS
        exception_id        NUMBER;
        exception_message   VARCHAR2(2000);
    BEGIN
        lookup_exception(exception_label_in, exception_id, exception_message);
        RAISE_APPLICATION_ERROR(exception_id, exception_message);    
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
        RAISE_APPLICATION_ERROR(-20001, 'Unable to lookup exception with label (' || exception_label_in || ')');    
    END raise_exception;

    procedure raise_exception_val(
	exception_label_in in varchar2,
	val_in in number
    ) is
	exception_id        NUMBER;
	exception_message   VARCHAR2(2000);
    begin
	lookup_exception(exception_label_in, exception_id, exception_message);
	RAISE_APPLICATION_ERROR(exception_id, exception_message || ' (' || val_in || ')');
    exception
	when no_data_found then
	RAISE_APPLICATION_ERROR(-20001, 'Unable to lookup exception with label (' || exception_label_in || ')');
    end raise_exception_val;
    
END rhn_exception;
/
SHOW ERRORS

-- $Log$
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--
