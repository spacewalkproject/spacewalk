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
create table
rhnActionVirtSuspend
(
    action_id   number  
                constraint rhn_avsuspend_aid_nn not null
                constraint rhn_avsuspend_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avsuspend_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avsuspend_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avsuspend_mod_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create unique index rhn_avsuspend_aid_uq
    on rhnActionVirtSuspend( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtSuspend add constraint rhn_avsuspend_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avsuspend_mod_trig
before insert or update on rhnActionVirtSuspend
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
