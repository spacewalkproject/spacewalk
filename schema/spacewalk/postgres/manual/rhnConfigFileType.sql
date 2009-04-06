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


create table rhnConfigFileType
(
	id			numeric not null
				constraint rhn_conffiletype_id_pk primary key,
--					using index tablespace [[2m_tbs]],
   label    varchar(64) not null,
   name     varchar(256) not null,
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null
)
;
/*
create or replace trigger
rhn_conffiletype_mod_trig
before insert or update on rhnConfigFile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

--
--
-- Revision 1.2  2005/02/10 21:45:41  jslagle
-- Added documentation changes
--
--
