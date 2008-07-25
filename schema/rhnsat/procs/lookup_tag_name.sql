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
LOOKUP_TAG_NAME(name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	name_id     NUMBER;
BEGIN
        select id into name_id
	  from rhnTagName
	 where name = name_in;

        RETURN name_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTagName(id, name)
                    values (rhn_tagname_id_seq.nextval, name_in)
                    returning id into name_id;
            COMMIT;
            RETURN name_id;
END;
/
SHOW ERRORS

-- $Log$
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
