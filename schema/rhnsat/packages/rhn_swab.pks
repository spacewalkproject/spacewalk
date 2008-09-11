--
-- $Id$
--
-- XXX should be dev
-- EXCLUDE: all

CREATE OR REPLACE
PACKAGE rhn_swab
IS
    CURSOR message_cursor(recipient_in VARCHAR2, message_type_id_in NUMBER) IS
    SELECT *
      FROM rhnSwabMessage SM
     WHERE recipient = recipient_in
       AND message_type = message_type_id_in
    ORDER BY priority DESC, created DESC
    FOR UPDATE;    

    FUNCTION insert_message(recipient_in VARCHAR2, message_type_in VARCHAR2, priority_in NUMBER, body_in VARCHAR2) RETURN NUMBER;
    FUNCTION receive_message(recipient_in VARCHAR2, message_type_in VARCHAR2) RETURN VARCHAR2;
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
