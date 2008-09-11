--
-- $Id$
--

create table
rhnPollChoice
(
        id              number
			constraint rhn_poll_choice_id_nn not null
                        constraint rhn_poll_choice_id_pk primary key
				using index tablespace rhn_ind
				storage ( initial 40960 
					next 507904 pctincrease 1 ),
	poll_id		number
			constraint rhn_poll_choice_pid_nn not null
			constraint rhn_poll_choice_pid_fk
				references rhnPoll(id),
	text		varchar2(512)
			constraint rhn_poll_choice_text_nn not null,
	position	number,
	created		date default(sysdate)
			constraint rhn_poll_choice_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_poll_choice_modified_nn not null
)
storage ( initial 40960 next 5816320 pctincrease 1 );

create sequence rhn_poll_choice_id_seq;

create or replace trigger
rhn_poll_choice_mod_trig
before insert or update on rhnPoll
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.2  2001/12/11 16:03:03  pjones
-- add position on each of these.  Note that it's nullable, so if somebody
-- wanted to only specify which question came first, and not care about the
-- rest, that'd work.
--
-- Revision 1.1  2001/12/10 22:19:09  pjones
-- initial checkin of user poll schema
--
