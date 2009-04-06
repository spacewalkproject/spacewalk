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
create table rhnVisibleObjects(
  pxt_session_id numeric not null,
  object_id numeric not null,
  object_type varchar(40) not null,
  constraint rhn_vis_objs_sess_fk
    foreign key (pxt_session_id)
    references PXTSessions(id)
    on delete cascade,
constraint rhn_vis_objs_sess_obj_type_idx unique (pxt_session_id, object_id, object_type)
)
;


