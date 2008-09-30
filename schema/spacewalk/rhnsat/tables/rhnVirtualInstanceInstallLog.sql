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


create table
rhnVirtualInstanceInstallLog
(
    id                 number
                           constraint rhn_viil_id_nn not null
                           constraint rhn_viil_id_pk primary key
                           using index tablespace [[64k_tbs]],
    log_message        varchar2(4000)
                           constraint rhn_viil_lm_nn not null,
    ks_session_id      number
                           constraint rhn_viil_ks_sid_fk
                               references rhnKickstartSession(id)
                               on delete cascade,
    created            date default (sysdate)
                           constraint rhn_viil_created_nn not null,
    modified           date default (sysdate)
                           constraint rhn_viil_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create sequence rhn_viil_id_seq;

-- $Log$
