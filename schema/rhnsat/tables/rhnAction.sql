--
-- $Id$
--

create table
rhnAction
(
	id		number
			constraint rhn_action_id_nn not null
			constraint rhn_action_pk primary key
			using index tablespace [[4m_tbs]],
	org_id		number
			constraint rhn_action_oid_nn not null
			constraint rhn_action_oid_fk
				references web_customer(id)
				on delete cascade,
	action_type	number
			constraint rhn_action_at_nn not null
			constraint rhn_action_at_fk
				references rhnActionType(id),
	name            varchar2(128),
	scheduler	number
			constraint rhn_action_scheduler_fk
				references web_contact(id)
				on delete set null,
	earliest_action	date 
			constraint rhn_action_ea_nn not null,
	version		number default 0
			constraint rhn_action_version_nn not null,
	archived        number default 0
	    	    	constraint rhn_action_archived_nn not null
			constraint rhn_action_archived_ck
				check (archived in (0, 1)),
        prerequisite    number
                        constraint rhn_action_prereq_fk
                                references rhnAction(id) on delete cascade,
	created		date default (sysdate) 
			constraint rhn_action_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_action_modified_nn not null
)
	storage ( freelists 16 )
	initrans 32;

-- this is common with the stuff used by rhnServerHistory now
create sequence rhn_event_id_seq;

create index rhn_action_oid_idx
	on rhnAction(org_id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index rhn_action_scheduler_idx
	on rhnAction(scheduler)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create index rhn_action_prereq_id_idx
        on rhnAction(prerequisite, id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_action_mod_trig
before insert or update on rhnAction
for each row
begin
        :new.modified := sysdate;
end;
/
show errors


-- $Log$
-- Revision 1.25  2003/10/08 22:20:41  misa
-- Added id to the prerequisite index, better explain plain
--
-- Revision 1.24  2003/10/08 18:02:31  misa
-- Index needed on prerequisite
--
-- Revision 1.23  2003/10/06 22:02:35  misa
-- bugzilla: none  Action prerequisites
--
-- Revision 1.22  2003/09/17 15:39:02  pjones
-- bugzilla: 104574
--
-- version is no longer nullable.  It wasn't ever valid data anyway
--
-- Revision 1.21  2003/03/17 16:31:25  pjones
-- use "on delete set null" where applicable
--
-- Revision 1.20  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.19  2003/03/03 23:26:18  pjones
-- this makes fixing it on user deletion tolerable
--
-- Revision 1.18  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.17  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.16  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
