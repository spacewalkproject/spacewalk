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
rhnKickstartCommand
(
    id                          numeric
                                constraint rhn_kscommand_id_pk primary key
--                              using index tablespace [[4m_tbs]]
                                ,
	kickstart_id		numeric
				not null
				constraint rhn_kscommand_ksid_fk
				references rhnKSData(id)
				on delete cascade,
	ks_command_name_id	numeric
				not null
				constraint rhn_kscommand_kcnid_fk
				references rhnKickstartCommandName(id),
    	arguments               varchar(2048),
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null
)
  ;

create sequence rhn_kscommand_id_seq;

create index rhn_kscommand_ksid_idx
	on rhnKickstartCommand( kickstart_id )
--	tablespace [[4m_tbs]]
        ;
/*
create or replace trigger
rhn_kscommand_mod_trig
before insert or update on rhnKickstartCommand
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.5  2004/01/28 17:40:58  pjones
-- bugzilla: 112166 -- make rhnKickstartCommand.arguments longer
--
-- Revision 1.4  2003/09/17 16:45:37  rnorwood
-- bugzilla: 103307 - rename rhnKickstart due to extreme weirdness with Oracle::DBD.
--
-- Revision 1.3  2003/09/16 16:16:47  rnorwood
-- bugzilla: 101151 - commit and load kickstart files.
--
-- Revision 1.2  2003/09/16 15:05:51  pjones
-- bugzilla: none
--
-- doesn't need an ID
--
-- Revision 1.1  2003/09/11 20:55:42  pjones
-- bugzilla: 104231
--
-- tables to handle kickstart data
--
