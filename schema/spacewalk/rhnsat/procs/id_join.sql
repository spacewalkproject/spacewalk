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

CREATE OR REPLACE FUNCTION
ID_JOIN(sep_in IN VARCHAR2, ugi_in IN user_group_id_t)
RETURN VARCHAR2
deterministic
IS
	ret	VARCHAR2(4000);
	i	BINARY_INTEGER;
BEGIN
	ret := '';
	i := ugi_in.FIRST;

	IF i IS NULL
	THEN
		RETURN ret;
	END IF;

	ret := ugi_in(i);
	i := ugi_in.NEXT(i);

	WHILE i IS NOT NULL
	LOOP
		ret := ret || sep_in || ugi_in(i);
		i := ugi_in.NEXT(i);
	END LOOP;

	RETURN ret;
END;
/
SHOW ERRORS

--
-- Revision 1.2  2002/05/13 22:53:38  pjones
-- cvs id/log
-- some (note enough) readability fixes
--
