-- oracle equivalent source sha1 942b2bf4eda45273311232fcaa5174f8bfc47123
-- retrieved from ./1235013416/07c0bfbb6902a98d09f8a41896bd55900645af6b/schema/spacewalk/rhnsat/views/rhnUserTypeCommaView.sql
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
create or replace view rhnUserTypeCommaView (
       user_id, ids, labels, names
)
as
select
    C.id,
    array_to_string( array(select utb.type_id
                           from rhnUserTypeBase utb
                           where utb.user_id = C.id), ', ' ),
    array_to_string( array(select utb.type_label
                           from rhnUserTypeBase utb
                           where utb.user_id = C.id), ', ' ),
    array_to_string( array(select utb.type_name
                           from rhnUserTypeBase utb
                           where utb.user_id = C.id), ', ' )
from	   
    web_contact as C
;

