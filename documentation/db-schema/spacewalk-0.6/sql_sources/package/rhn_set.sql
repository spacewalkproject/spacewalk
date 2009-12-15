-- created by Oraschemadoc Mon Aug 31 10:54:43 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM1"."RHN_SET" 
IS
    CURSOR set_iterator(set_label_in IN VARCHAR2, set_user_id_in IN NUMBER) IS
    	   SELECT user_id, label, element, element_two
	     FROM rhnSet
	    WHERE label = set_label_in
	      AND user_id = set_user_id_in;
END rhn_set;
CREATE OR REPLACE PACKAGE BODY "MIM1"."RHN_SET" 
IS
END rhn_set;
 
/
