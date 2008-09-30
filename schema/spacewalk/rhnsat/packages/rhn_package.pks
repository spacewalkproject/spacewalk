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
      RETURN VARCHAR2
      DETERMINISTIC;

    FUNCTION channel_occupancy_string(package_id_in IN NUMBER, separator_in VARCHAR2 := ', ') 
      RETURN VARCHAR2;
      
END rhn_package;
/
SHOW ERRORS

--
-- Revision 1.3  2002/05/10 22:08:23  pjones
-- id/log
--
