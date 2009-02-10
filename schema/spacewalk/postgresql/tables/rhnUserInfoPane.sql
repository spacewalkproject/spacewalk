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

create table rhnUserInfoPane (
    user_id numeric 
            not null
            constraint rhn_usr_info_pane_uid_fk 
                references web_contact(id)
                on delete cascade,
    pane_id numeric
            not null
            constraint rhn_usr_info_pane_pid_fk 
                references rhnInfoPane(id)
                on delete cascade,
                constraint rhnusrinfopane_uid_pid_uq
                unique( user_id, pane_id )
                using index tablespace [[4m_tbs]]
)
  ;


