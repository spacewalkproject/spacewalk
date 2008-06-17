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
rhnActionVirtVcpu
(
    action_id   number  
                constraint rhn_avcpu_aid_nn not null
                constraint rhn_avcpu_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    uuid        varchar(128)
                constraint rhn_avcpu_uuid_nn not null,
    vcpu      number
                constraint rhn_avcpu_vcpus_nn not null,
    created     date default(sysdate)
                constraint rhn_avcpu_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avcpu_mod_nn not null
)
    storage ( freelists 16 )
    initrans 32;

create unique index rhn_avcpu_aid_uq
    on rhnActionVirtVcpu( action_id )
    tablespace [[8m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhnActionVirtVcpu add constraint rhn_avcpu_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avcpu_mod_trig
before insert or update on rhnActionVirtVcpu
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
