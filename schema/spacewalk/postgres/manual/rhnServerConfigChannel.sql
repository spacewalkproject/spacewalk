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

-- this keeps track of which servers are subscribed to which
-- config channels 

create table
rhnServerConfigChannel
(
	server_id		numeric
				not null
				constraint rhn_servercc_sid_fk
				references rhnServer(id),
	config_channel_id	numeric
				not null
				constraint rhn_servercc_ccid_fk
				references rhnConfigChannel(id)
				on delete cascade,
	position		numeric,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_servercc_sid_ccid_uq
                                unique( server_id, config_channel_id )
--                              using index tablespace [[2m_tbs]]
)
  ;

-- this one is needed for the deletion on rhnConfigChannel
create index rhn_servercc_ccid_idx
	on rhnServerConfigChannel( config_channel_id )
--	tablespace [[2m_tbs]]
  ;

/*
create or replace trigger
rhn_servercc_mod_trig
before insert or update on rhnServerConfigChannel
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
--
-- Revision 1.5  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.4  2003/12/18 16:29:10  pjones
-- bugzilla: none -- the trigger way won't work, back it out
--
-- Revision 1.3  2003/12/17 16:21:08  pjones
-- bugzilla: 108446 -- add a trigger to prune rhnConfigChannel for certain
-- deletes from rhnServerConfigChannel.
--
-- Revision 1.2  2003/11/09 17:36:08  pjones
-- bugzilla: 109083 -- server config channel needs a position
--
-- Revision 1.1  2003/11/09 16:58:00  pjones
-- bugzilla: 109083 -- associate a server with a config channel
--
