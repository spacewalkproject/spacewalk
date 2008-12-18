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
rhnActionVirtStart
(
    action_id   number  
                constraint rhn_avstart_aid_nn not null,
    uuid        varchar2(128)
                constraint rhn_avstart_uuid_nn not null,
    created     date default(sysdate)
                constraint rhn_avstart_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avstart_mod_nn not null
)
    enable row movement
  ;

create unique index rhn_avstart_aid_uq
    on rhnActionVirtStart( action_id )
    tablespace [[8m_tbs]]
  ;

alter table rhnActionVirtStart add constraint rhn_avstart_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avstart_mod_trig
before insert or update on rhnActionVirtStart
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
