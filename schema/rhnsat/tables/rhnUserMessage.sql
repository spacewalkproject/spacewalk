-- $Id$

-- ties a message to a user
create table
rhnUserMessage
(
	user_id		number
			constraint rhn_um_user_id_nn not null
			constraint rhn_um_user_id_fk
				references web_contact(id),
	message_id	number
			constraint rhn_um_message_id_nn not null
			constraint rhn_um_message_id_fk
				references rhnMessage(id)
				on delete cascade,
	status		number
			constraint rhn_um_status_nn not null
			constraint rhn_um_status_fk
				references rhnUserMessageStatus(id)
)
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_um_uid_mid_uq
	on rhnUserMessage(user_id, message_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.7  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.6  2002/08/13 19:17:59  pjones
-- cascades
--
-- Revision 1.5  2002/07/25 19:57:22  pjones
-- missed these?
--
