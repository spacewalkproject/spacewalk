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
--/

create table
rhnPackageChangelog
(
        id              numeric
                        constraint rhn_pkg_cl_id_pk primary key
--                      using index tablespace [[64k_tbs]]
                        ,
	package_id      numeric
                        not null
                        constraint rhn_pkg_changelog_pid_fk
			references rhnPackage(id)
                        on delete cascade,
        name            varchar(128)
			not null,
        text            varchar(3000)
			not null,
        time            date
			not null,
        created         date default(current_date)
			not null,
        modified        date default(current_date)
			not null,
                        constraint rhn_pkg_cl_pid_n_txt_time_uq
                        unique(package_id, name, text, time)
--                      using index tablespace [[32m_tbs]]
)
  ;

create sequence rhn_pkg_cl_id_seq;

/*
create or replace trigger 
rhn_package_changelog_mod_trig
before insert or update on rhnPackageChangelog
for each row 
begin 
        :new.modified := sysdate; 
end;
/
*/

/*
create or replace trigger
rhn_package_changelog_id_trig
before insert on rhnPackageChangelog
for each row
when (new.id is null)
begin
        select rhn_pkg_cl_id_seq.nextval into :new.id from dual;
end;
/ 
show errors 
*/
--
-- Revision 1.19  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.16  2002/04/30 16:24:12  misa
-- The index is unique now.
--
-- Revision 1.15  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
