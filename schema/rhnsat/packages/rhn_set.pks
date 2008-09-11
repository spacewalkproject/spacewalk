--
-- $Id$
--

CREATE OR REPLACE
PACKAGE rhn_set
IS
    CURSOR set_iterator(set_label_in IN VARCHAR2, set_user_id_in IN NUMBER) IS
    	   SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_user_id_in;
END rhn_set;
/
SHOW ERRORS

-- $Log$
-- Revision 1.3  2002/05/10 22:08:23  pjones
-- id/log
--
