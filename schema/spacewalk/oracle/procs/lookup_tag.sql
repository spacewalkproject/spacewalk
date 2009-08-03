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
LOOKUP_TAG(org_id_in IN NUMBER, name_in IN VARCHAR2)
RETURN NUMBER
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
	tag_id     NUMBER;
BEGIN
        select id into tag_id
	  from rhnTag
	 where org_id = org_id_in
	   and name_id = lookup_tag_name(name_in);

        RETURN tag_id;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
            insert into rhnTag(id, org_id, name_id)
                    values (rhn_tag_id_seq.nextval, org_id_in, lookup_tag_name(name_in))
                    returning id into tag_id;
            COMMIT;
            RETURN tag_id;
END;
/
SHOW ERRORS

--
-- Revision 1.1  2003/10/16 14:23:33  bretm
-- bugzilla:  107189
--
-- o  added server_id to rhnSnapshotTag
-- o  added lookup_tag(org_id, tagname)
--
