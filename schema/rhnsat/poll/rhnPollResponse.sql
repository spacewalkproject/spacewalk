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
-- $Id$
--

create table
rhnPollResponse
(
	web_contact_id	number
			constraint rhn_poll_response_wcid_nn not null
			constraint rhn_poll_response_wcid_fk
				references web.web_contact(id),
	poll_question_id number
			constraint rhn_poll_response_pqid_nn not null
			constraint rhn_poll_response_pqid_fk
				references rhnPollQuestion(id),
	poll_choice_id	number
			constraint rhn_poll_response_pcid_fk
				references rhnPollChoice(id),
	answer		varchar2(4096),
	created		date default(sysdate)
			constraint rhn_poll_response_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_poll_response_modified_nn not null
)
storage ( initial 40960 next 5816320 pctincrease 1 );

create sequence rhn_poll_response_id_seq;

create or replace trigger
rhn_poll_response_mod_trig
before insert or update on rhnPoll
for each row
	question	rhnPollQuestion%ROWTYPE;
begin
        :new.modified := sysdate;
	select	rpq.*
		into	question
		from	rhnPollQuestion rpq
		where	rpq.id = :new.poll_question_id;
	if question.question_type == 1 and
			(question.poll_choice_id is not null or
			 question.answer is null) then
		raise VALUE_ERROR;
	end if;
	if question.question_type in (2,3) and
			(question.answer is not null or
			 question.poll_choice_id is null) then
		raise VALUE_ERROR;
	end if;
end;
/
show errors

-- $Log$
-- Revision 1.2  2001/12/12 16:46:45  pjones
-- add question type to rhnPollQuestion
-- add rhnPollQuestionType
-- add answer and remove poll_choice_id's not null on rhnPollResponse
-- add verification trigger on rhnPollResponse
-- fix values in rhnPollState
--
-- Revision 1.1  2001/12/10 22:19:09  pjones
-- initial checkin of user poll schema
--
