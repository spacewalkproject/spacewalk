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
-- $Id$
--

CREATE OR REPLACE FUNCTION
LOOKUP_SERVER_ARCH(label_in IN VARCHAR2)
RETURN NUMBER
IS
	server_arch_id		NUMBER;
BEGIN
	SELECT id
          INTO server_arch_id
          FROM rhnServerArch
         WHERE label = label_in;

	RETURN server_arch_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            rhn_exception.raise_exception('server_arch_not_found');
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.2  2004/02/20 18:08:51  pjones
-- bugzilla: none -- make lookup_*_arch.sql not autonomous since they never
-- insert
-- add changes files for nonlinux systems
--
-- Revision 1.1  2002/11/13 23:16:18  pjones
-- lookup_*_arch()
--
