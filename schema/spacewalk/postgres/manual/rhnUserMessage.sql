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

-- ties a message to a user
create table
rhnUserMessage
(
	user_id		numeric
			not null
			constraint rhn_um_user_id_fk
				references web_contact(id),
	message_id	numeric
			not null
			constraint rhn_um_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	status		numeric
			not null
			constraint rhn_um_status_fk
				references rhnUserMessageStatus(id),
                        constraint rhn_um_uid_mid_uq 
                        unique(user_id, message_id)
--                        using index tablespace [[64k_tbs]]
)
 ;

--
-- Revision 1.7  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.6  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.5  2002/07/25 19:57:22  pjones
-- missed these?
--
