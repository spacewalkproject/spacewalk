--
-- $Id$

create table
rhnServerLock
(
        server_id       number
			constraint rhn_server_lock_sid_nn not null
                        constraint rhn_server_lock_sid_fk
				references rhnServer(id),
        locker_id       number
                        constraint rhn_server_lock_lid_fk
				references web_contact(id) on delete set null,
	reason          varchar2(4000),
        created         date default (sysdate)
			constraint rhn_server_lock_created_nn not null
)
	storage ( pctincrease 1 freelists 16 )
	initrans 32;

create unique index rhn_server_lock_sid_unq on
        rhnServerLock(server_id)
	tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

create index rhn_server_lock_lid_unq on
        rhnServerLock(locker_id)
	tablespace [[4m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;
