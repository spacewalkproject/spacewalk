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

create sequence rhn_ksinstalltype_id_seq;

create table
rhnKSInstallType
(
        id              numeric not null
                        constraint rhn_ksinstalltype_id_pk primary key,
--                                using index tablespace [[64k_tbs]],
        label           varchar(32) not null
			constraint rhn_ksinstalltype_label_uq unique, 
--        		using index tablespace [[64k_tbs]]
        name            varchar(64) not null,
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null
)
  ;

/*
create or replace trigger
rhn_ksinstalltype_mod_trig
before insert or update on rhnKSInstallType
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.2  2003/12/12 21:19:35  pjones
-- bugzilla: none -- fix somebody's very very sloppy table creation.
--
