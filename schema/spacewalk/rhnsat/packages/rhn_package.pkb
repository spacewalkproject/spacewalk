--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

CREATE OR REPLACE
PACKAGE BODY rhn_package
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
SHOW ERRORS

--
-- Revision 1.3  2002/05/10 22:08:23  pjones
-- id/log
--
