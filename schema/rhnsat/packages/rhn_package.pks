--
-- $Id$
--

CREATE OR REPLACE
PACKAGE rhn_package
IS
    CURSOR channel_occupancy_cursor(package_id_in IN NUMBER) IS
    SELECT C.id channel_id, C.name channel_name
      FROM rhnChannel C,
      	   rhnChannelPackage CP
     WHERE C.id = CP.channel_id
       AND CP.package_id = package_id_in
     ORDER BY C.name DESC;

    FUNCTION canonical_name(name_in IN VARCHAR2, evr_in IN EVR_T, 
    	                    arch_in IN VARCHAR2 := NULL)
      RETURN VARCHAR2;

    FUNCTION channel_occupancy_string(package_id_in IN NUMBER, separator_in VARCHAR2 := ', ') 
      RETURN VARCHAR2;
      
END rhn_package;
/
SHOW ERRORS

-- $Log$
-- Revision 1.3  2002/05/10 22:08:23  pjones
-- id/log
--
