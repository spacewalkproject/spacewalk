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
rhnServerHistory
(
        id              numeric not null
                        constraint rhn_serverhistory_id_pk primary key,
--                        using index tablespace [[2m_tbs]],
        server_Id       numeric not null
                        constraint rhn_serverhistory_sid_fk
                                references rhnServer(id),
        summary         varchar(256) not null,
        details         varchar(4000),
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null
)
  ;

create index rhn_server_hist_server_id_idx
	on rhnServerHistory(server_id)
--	tablespace [[4m_tbs]]
  ;
  
-- we use the rhn_event_id_seq for the history ids
/*
create or replace trigger
rhn_serverhistory_mod_trig
before insert or update on rhnServerHistory
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.16  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.15  2003/10/15 14:56:39  pjones
-- bugzilla: none
-- make rhnServerHistory.summary bigger for bretm
--
-- Revision 1.14  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.13  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
