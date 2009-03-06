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

-- information about a server event
create table
rhnServerEvent
(
	id		numeric
			constraint rhn_se_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	server_id	numeric
			not null
			constraint rhn_se_server_id_fk
			references rhnServer(id),
	details 	varchar(4000)
			not null,
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null
)
  ;

create index rhn_se_idx
	on rhnServerEvent(server_id)
--	tablespace [[64k_tbs]]
        ;

create sequence rhn_se_id_seq;

/*
create or replace trigger
rhn_se_mod_trig
before insert or update on rhnServerEvent
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/


--
-- Revision 1.5  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/08/14 22:07:48  cturner
-- add index on server_id to avoid full table locks when someone tries to delete a server
--
-- Revision 1.2  2002/08/13 19:17:58  pjones
-- cascades
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
