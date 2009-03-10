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
-- a generic message
create table
rhnMessage
(
	id		numeric
			constraint rhn_m_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	message_type	numeric
			not null
			constraint rhn_m_mt_fk
			references rhnMessageType(id),
	priority	numeric default 0
			not null
			constraint rhn_m_priority_fk
			references rhnMessagePriority(id),
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null
)
  ;

create sequence rhn_m_id_seq;
/*
create or replace trigger
rhn_m_mod_trig
before insert or update on rhnMessage
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/08/11 19:51:58  cturner
-- simple deploy script for testing and typo fix in messaging schema
--
-- Revision 1.2  2002/07/29 20:26:23  pjones
-- add support for labeled message priorities
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
