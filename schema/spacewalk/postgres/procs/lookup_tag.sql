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
LOOKUP_TAG(org_id_in IN NUMERIC, name_in IN VARCHAR)
RETURNS NUMERIC
as $$
DECLARE
        tag_id     NUMERIC;
BEGIN
        select id into tag_id
          from rhnTag
         where org_id = org_id_in
           and name_id = lookup_tag_name(name_in);

           IF NOT FOUND THEN
		insert into rhnTag(id, org_id, name_id) values (nextval('rhn_tag_id_seq'), org_id_in, lookup_tag_name(name_in));
		tag_id := currval('rhn_tag_id_seq');
           END IF;

        RETURN tag_id;
END; $$
LANGUAGE PLPGSQL;
