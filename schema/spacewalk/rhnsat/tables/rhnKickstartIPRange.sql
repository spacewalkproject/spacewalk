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
rhnKickstartIPRange
(
        kickstart_id            number
                                constraint rhn_ksip_ksid_nn not null
                                constraint rhn_ksip_ksid_fk
                                        references rhnKSData(id)
                                        on delete cascade,
        org_id                  number
                                constraint rhn_ksip_oid_nn not null
                                constraint rhn_ksip_oid_fk
                                        references  web_customer(id)
                                        on delete cascade,
        min                     number
                                constraint rhn_ksip_min_nn not null,
        max                     number
                                constraint rhn_ksip_max_nn not null,
        created                 date default(sysdate)
                                constraint rhn_ksip_created_nn not null,
        modified                date default(sysdate)
                                constraint rhn_ksip_modified_nn not null
)
        storage ( freelists 16 )
	enable row movement
        initrans 32;

create index rhn_ksip_kickstart_id_idx
        on rhnKickstartIPRange( kickstart_id )
        tablespace [[4m_tbs]]
        storage ( freelists 16 )
        initrans 32;

create index rhn_ksip_org_id_idx
        on rhnKickstartIPRange( org_id )
        tablespace [[4m_tbs]]
        storage ( freelists 16 )
        initrans 32;

alter table rhnKickstartIPRange add constraint rhn_ksip_oid_min_max_uq
       	unique ( org_id, min, max );

create or replace trigger
rhn_ksip_mod_trig
before insert or update on rhnKickstartIPRange
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

