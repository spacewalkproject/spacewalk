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

--
-- Revision 1.3  2002/05/10 22:08:23  pjones
-- id/log
--
