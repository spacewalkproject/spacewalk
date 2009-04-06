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

