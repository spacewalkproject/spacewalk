--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

create table
rhnPollQuestion
(
        id              number
			constraint rhn_poll_question_id_nn not null
                        constraint rhn_poll_question_id_pk primary key
				using index tablespace rhn_ind
				storage ( initial 40960 
					next 507904 pctincrease 1 ),
	poll_id		number
			constraint rhn_poll_question_pid_nn not null
			constraint rhn_poll_question_pid_fk
				references rhnPoll(id),
	question_type	number
			constraint rhn_poll_question_type_nn not null
			constraint rhn_poll_question_type_fk
				referneces rhnPollQuestionType(id),
	text		varchar2(512)
			constraint rhn_poll_question_name_nn not null,
	position	number,
	created		date default(sysdate)
			constraint rhn_poll_question_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_poll_question_modified_nn not null
)
storage ( initial 40960 next 5816320 pctincrease 1 );

create sequence rhn_poll_question_id_seq;

create or replace trigger
rhn_poll_question_mod_trig
before insert or update on rhnPoll
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.3  2001/12/12 16:46:45  pjones
-- add question type to rhnPollQuestion
-- add rhnPollQuestionType
-- add answer and remove poll_choice_id's not null on rhnPollResponse
-- add verification trigger on rhnPollResponse
-- fix values in rhnPollState
--
-- Revision 1.2  2001/12/11 16:03:03  pjones
-- add position on each of these.  Note that it's nullable, so if somebody
-- wanted to only specify which question came first, and not care about the
-- rest, that'd work.
--
-- Revision 1.1  2001/12/10 22:19:09  pjones
-- initial checkin of user poll schema
--
