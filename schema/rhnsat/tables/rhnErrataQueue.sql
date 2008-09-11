--
-- $Id$
--

create table
rhnErrataQueue
(
	errata_id		number
				constraint rhn_equeue_eid_nn not null
				constraint rhn_equeue_eid_fk
					references rhnErrata(id)
					on delete cascade,
	next_action		date,
	created			date default(sysdate)
				constraint rhn_equeue_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_equeue_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

create index rhn_equeue_eid_idx
	on rhnErrataQueue ( errata_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
	
alter table rhnErrataQueue add constraint rhn_equeue_eoid_uq
	unique ( errata_id );

create index rhn_equeue_na_eid_idx
	on rhnErrataQueue ( next_action, errata_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;
