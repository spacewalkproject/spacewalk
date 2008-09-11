--
-- $Id$
--

create table PXTSessions (
        id              number,
        web_user_id     number
                        constraint pxtsessions_user
	                        references web_contact(id) on delete cascade,
        expires         number default 0
                        constraint pxtsessions_expires_nn not null,
        value           varchar2(4000)
                        constraint pxtsessions_value_nn not null
)
	organization heap
	storage	( freelists 16 )
	initrans	32
	nocache nomonitoring nologging;

create unique index pxt_sessions_pk
	on PXTSessions(id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

alter table PXTSessions add constraint pxt_sessions_pk
	primary key (id);

create sequence pxt_id_seq;

create index PXTSessions_user
	on PXTSessions(web_user_id) 
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index PXTSessions_expires
	on PXTSessions(expires)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

-- $Log$
-- Revision 1.12  2003/10/13 14:14:52  pjones
-- bugzilla: none
-- make this table's storage parameters look like all the others; for some
-- reason the current settings blow up bad sometimes.
--
-- Revision 1.11  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.10  2002/12/23 21:39:06  misa
-- Fixing typo
--
-- Revision 1.9  2002/12/03 21:11:57  pjones
-- match don's new INITTRANS/STORAGE changes
--
-- Revision 1.8  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
