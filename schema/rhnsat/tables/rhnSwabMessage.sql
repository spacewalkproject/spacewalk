--
-- $Id$
--
-- XXX: should be dev
-- EXCLUDE: all

CREATE TABLE
rhnSwabMessage
(
	id		number
			constraint rhn_swab_msg_id_nn not null
			constraint rhn_swab_msg_id_pk primary key,
    	recipient	varchar2(256)
	    	    	constraint rhn_swab_msg_rcp_nn not null,
	message_type	number
	    	    	constraint rhn_swab_msg_type_nn not null
			constraint rhn_swab_msg_type_fk
				references rhnSwabMessageType(id),
	priority	number default 0
			constraint rhn_swab_msg_pri_nn not null,
	body		varchar2(4000)
	    	    	constraint rhn_swab_msg_body_nn not null,
	created		date default (sysdate)
			constraint rhn_swab_msg_created_nn not null			
)
	storage ( freelists 16 )
	initrans 32;

create sequence rhn_swab_message_id_seq;

create index rhn_swab_msg_r_mt_idx
	on rhnSwabMessage(recipient,message_type)
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
