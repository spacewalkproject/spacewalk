--
-- $Id$
--

create table
rhnErrataNotificationQueue
(
	errata_id		number
				constraint rhn_enqueue_eid_nn not null
				constraint rhn_enqueue_eid_fk
					references rhnErrata(id)
					on delete cascade,
        org_id                  number
                            	constraint rhn_enqueue_oid_nn not null
                            	constraint rhn_enqueue_oid_fk
                                	references web_customer(id)
					on delete cascade,
	next_action		date,
	created			date default(sysdate)
				constraint rhn_enqueue_created_nn not null,
	modified		date default(sysdate)
				constraint rhn_enqueue_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_enqueue_eid_idx
	on rhnErrataNotificationQueue ( errata_id, org_id )
	tablespace [[4m_tbs]]
	storage ( freelists 16 )
	initrans 32;
alter table rhnErrataNotificationQueue add constraint rhn_enqueue_eoid_uq
	unique ( errata_id, org_id );

create index rhn_enqueue_na_eid_idx
	on rhnErrataNotificationQueue ( next_action, errata_id )
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_enqueue_mod_trig
before insert or update on rhnErrataNotificationQueue
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.4  2003/08/14 20:01:14  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.3  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.2  2003/02/25 18:46:37  cturner
-- add org id to the errata notification queue so that we can split big jobs up properly
--
-- Revision 1.1  2003/02/14 16:08:57  pjones
-- errata notification queue
--
