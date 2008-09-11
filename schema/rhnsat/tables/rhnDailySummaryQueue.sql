--
-- $Id$
--

create table
rhnDailySummaryQueue
(
	org_id		number
			constraint rhn_dsqueue_oid_nn not null
			constraint rhn_dsqueue_oid_fk
				references web_customer(id),
	created		date default(sysdate)
			constraint rhn_dsqueue_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_dsqueue_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_dsqueue_oid_idx
	on rhnDailySummaryQueue ( org_id )
	tablespace [[2m_tbs]]
	storage ( freelists 16 )
	initrans 32;
	
alter table rhnDailySummaryQueue add constraint rhn_dsqueue_oid_uq
	unique ( org_id );

-- $Log$
-- Revision 1.1  2003/03/19 17:22:23  pjones
-- daily summary queue for bretm
--
