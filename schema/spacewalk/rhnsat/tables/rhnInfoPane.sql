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

create table rhnInfoPane (
    id      number 
            constraint rhn_info_pane_id_pk primary key,
    label   varchar2(64)
            constraint rhn_info_pane_labl_nn not null,
    acl     varchar2(4000)
)
    enable row movement
  ;

create sequence rhn_info_pane_id_seq;

create unique index rhn_info_pane_labl_uq
    on rhnInfoPane (label)
    tablespace [[4m_tbs]]
  ;
