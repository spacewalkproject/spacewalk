--
-- $Id$
--

create table
rhnKickstartDefaultRegToken
(
	kickstart_id		number
				constraint rhn_ksdrt_ksid_nn not null
				constraint rhn_ksdrt_ksid_fk
					references rhnKSData(id)
					on delete cascade,
	regtoken_id		number
				constraint rhn_ksdrt_rtid_nn not null
				constraint rhn_ksdrt_rtid_fk
					references rhnRegToken(id)
					on delete cascade,
	created			date default (sysdate)
				constraint rhn_ksdrt_creat_nn not null,
	modified		date default (sysdate)
				constraint rhn_ksdrt_mod_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_ksdrt_ksid_rtid_idx
	on rhnKickstartDefaultRegToken( kickstart_id, regtoken_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- supports the "on delete cascade"
create index rhn_ksdrt_rtid_idx
	on rhnKickstartDefaultRegToken( regtoken_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_ksdrt_mod_trig
before insert or update on rhnKickstartDefaultRegToken
for each row
begin
	:new.modified := sysdate;
end rhn_ksdrt_mod_trig;
/
show errors

--
-- $Log$
-- Revision 1.2  2004/05/25 19:04:23  pjones
-- bugzilla: none -- remove the unique constraint, it's bogus.
--
-- Revision 1.1  2004/05/24 20:28:00  pjones
-- bugzilla: 121395 -- add support for more than one default activation key
-- for a kickstart session
--
