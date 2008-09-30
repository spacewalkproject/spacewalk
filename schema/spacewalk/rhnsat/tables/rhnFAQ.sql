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
-- Support for FAQs
--

create table
rhnFAQ
(
	id		number
			constraint rhn_faq_id_nn not null
			constraint rhn_faq_id_pk primary key
				using index tablespace [[64k_tbs]] 
                                storage(pctincrease 1),
	class_id	number
			constraint rhn_faq_class_fk
				references rhnFAQClass(id),
	subject		varchar2(200),
	details		varchar2(4000),
	private		number default(0)
			constraint rhn_faq_private_nn not null,
	usage_count     number default(0)
	    	    	constraint rhn_faq_usage_nn not null,
        created         date default(sysdate)
                        constraint rhn_faq_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_faq_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_faq_id_seq;

create or replace trigger
rhn_faq_mod_trig
before insert or update on rhnFAQ
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.14  2003/04/07 14:14:29  pjones
-- bugzilla: none
--
-- We want FAQ in satellite now.
--
-- Revision 1.13  2003/03/17 16:25:20  rnorwood
-- bugzilla: 85612 - bugfixes for FAQ class schema.
--
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/10/14 20:48:20  cturner
-- add usage count column to rhnFAQ table
--
-- Revision 1.10  2002/05/10 21:54:45  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
-- Revision 1.9  2002/05/09 03:13:24  gafton
-- Fix storage clauses to have saner defaults for people at large...
--
-- Revision 1.8  2002/05/08 23:10:12  gafton
-- Make file exclusion work correctly
--
-- Revision 1.7  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.6  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
-- Revision 1.5  2002/03/06 17:51:24  cturner
-- "set define off" is the proper approach to getting rid of ampersand escaping
--
-- Revision 1.4  2002/02/25 21:42:49  pjones
-- somebody check this to make sure i haven't mucked up the html content?
--
-- Revision 1.3  2002/02/22 11:07:58  cturner
-- add FAQ base questions to schema, and remove rhnUserFeedbackAutoResponse table.  From Patrick.
--
-- Revision 1.2  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.1  2001/09/27 23:52:12  gafton
-- Add the rhnFAQ and rhnUserFeedback tables
--
