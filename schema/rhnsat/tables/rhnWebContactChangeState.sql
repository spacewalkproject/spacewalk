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
create table rhnWebContactChangeState (
    id                     number
                           constraint rhn_cont_change_state_id_pk primary key,
    label                  varchar2(32)
                           constraint rhn_cont_change_state_nn not null
)
tablespace [[32m_tbs]]
storage( pctincrease 1 freelists 16 )
enable row movement
initrans 32;

create sequence rhn_wcon_change_state_seq;


--
-- $Log$
--
