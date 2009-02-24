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

-- supports adding arbitrary text to a message.  will allow in the future for 
-- user -> user messages?
create table
rhnTextMessage
(
	message_id	numeric not null
			constraint rhn_tm_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	message_body	varchar(4000) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;
/*
create or replace trigger
rhn_tm_mod_trig
before insert or update on rhnTextMessage
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
