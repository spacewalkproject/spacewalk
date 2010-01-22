-- created by Oraschemadoc Fri Jan 22 13:41:07 2010
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE PACKAGE "MIM_H1"."RHN_PACKAGE" 
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
      RETURN VARCHAR2
      DETERMINISTIC;

    FUNCTION channel_occupancy_string(package_id_in IN NUMBER, separator_in VARCHAR2 := ', ')
      RETURN VARCHAR2;

END rhn_package;
CREATE OR REPLACE PACKAGE BODY "MIM_H1"."RHN_PACKAGE" 
IS
    FUNCTION canonical_name(name_in IN VARCHAR2, evr_in IN EVR_T,
    	                    arch_in IN VARCHAR2)
    RETURN VARCHAR2
    IS
    	name_out     VARCHAR2(256);
    BEGIN
    	name_out := name_in || '-' || evr_in.as_vre_simple();

	IF arch_in IS NOT NULL
	THEN
	    name_out := name_out || '-' || arch_in;
	END IF;

        RETURN name_out;
    END canonical_name;

    FUNCTION channel_occupancy_string(package_id_in IN NUMBER, separator_in VARCHAR2 := ', ')
    RETURN VARCHAR2
    IS
    	list_out    VARCHAR2(4000);
    BEGIN
    	FOR channel IN channel_occupancy_cursor(package_id_in)
	LOOP
	    IF list_out IS NULL
	    THEN
	    	list_out := channel.channel_name;
	    ELSE
	        list_out := channel.channel_name || separator_in || list_out;
	    END IF;
	END LOOP;

	RETURN list_out;
    END channel_occupancy_string;

END rhn_package;
 
/
