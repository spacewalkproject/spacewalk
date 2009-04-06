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

-- ties a server to a message
create table
rhnServerMessage
(
	server_id	numeric
			not null
			constraint rhn_sm_server_id_fk
				references rhnServer(id),
	message_id	numeric
			not null
			constraint rhn_sm_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	server_event	numeric
			constraint rhn_sm_se_fk
				references rhnServerEvent(id)
				on delete cascade,
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null,
                        constraint rhn_sm_uq
                        unique(server_id, message_id)
--                      using index tablespace [[64k_tbs]]
                        ,
                        constraint rhn_sm_mi_sid_uq
                        unique(message_id, server_id)
--                      tablespace [[64k_tbs]]
)
  ;

create index RHN_SRVR_MSSG_SRVR_EVNT_IDX
on rhnServerMessage ( server_event )
--       tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_sm_mod_trig
before insert or update on rhnServerMessage
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
-- Revision 1.3  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.2  2002/08/02 19:36:02  rnorwood
-- add index to rhnServerMessage
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
