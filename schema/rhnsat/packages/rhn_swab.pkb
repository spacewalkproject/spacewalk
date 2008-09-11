--
-- $Id$
--
-- XXX should be dev
-- EXCLUDE: all


CREATE OR REPLACE
PACKAGE BODY rhn_swab
IS

    FUNCTION insert_message(recipient_in VARCHAR2, message_type_in VARCHAR2, priority_in NUMBER, body_in VARCHAR2) 
    RETURN NUMBER
    IS
        message_id          NUMBER;
        message_type_id     NUMBER;
    BEGIN

        SELECT rhn_swab_message_id_seq.nextval INTO message_id FROM DUAL;
        SELECT id INTO message_type_id FROM rhnSwabMessageType WHERE label = message_type_in;
        
        INSERT INTO rhnSwabMessage
               (id, recipient, message_type, priority, body)
        VALUES (message_id, recipient_in, message_type_id, priority_in, body_in);

        RETURN message_id;
    END insert_message;

    FUNCTION receive_message(recipient_in VARCHAR2, message_type_in VARCHAR2) 
    RETURN VARCHAR2
    IS
        message_id          NUMBER;
        message_type_id     NUMBER;
        body_ret            VARCHAR2(4000);
	message_rec         message_cursor%ROWTYPE;
    BEGIN

        SELECT id INTO message_type_id FROM rhnSwabMessageType WHERE label = message_type_in;

	OPEN message_cursor(recipient_in, message_type_id);
	
	FETCH message_cursor INTO message_rec;	
	IF message_cursor%FOUND
	THEN
	    body_ret := message_rec.body;
	    DELETE FROM rhnSwabMessage WHERE CURRENT OF message_cursor;
	END IF;
	
    	CLOSE message_cursor;

        RETURN body_ret;
    END receive_message;
    
END rhn_swab;
/
SHOW ERRORS

-- $Log$
-- Revision 1.2  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
