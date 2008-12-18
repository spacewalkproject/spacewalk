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
rhnActionVirtRefresh
(
    action_id   number  
                constraint rhn_avrefresh_aid_nn not null
                constraint rhn_avrefresh_aid_fk
                    references rhnAction(id)
                    on delete cascade,
    created     date default(sysdate)
                constraint rhn_avrefresh_creat_nn not null,
    modified    date default(sysdate)
                constraint rhn_avrefresh_mod_nn not null
)
    enable row movement
  ;

create unique index rhn_avrefresh_aid_uq
    on rhnActionVirtRefresh( action_id )
    tablespace [[8m_tbs]]
  ;

alter table rhnActionVirtRefresh add constraint rhn_avrefresh_aid_pk
    primary key ( action_id );

create or replace trigger
rhn_avrefresh_mod_trig
before insert or update on rhnActionVirtRefresh
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
