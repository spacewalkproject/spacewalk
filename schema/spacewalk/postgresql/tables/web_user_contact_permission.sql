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
-- contact permission for a contact
--
--

create table
web_user_contact_permission
(
	web_user_id		numeric not null
				constraint contperm_wbuserid_fk
					references web_contact(id)
					on delete cascade,
	email			char(1) default('N')
				constraint wucp_email_ck
					check (email in ('Y','N')),
	mail			char(1) default('N')
				constraint wucp_mail_ck
					check (mail in ('Y','N')),
	call			char(1) default('N')
				constraint wucp_call_ck
					check (call in ('Y','N')),
	fax			char(1) default('N')
				constraint wucp_fax_ck
					check (fax in ('Y','N')),
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null
)
	;
/*
create or replace trigger
web_user_cp_timestamp
BEFORE INSERT OR UPDATE ON web_user_contact_permission
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
END;
/
show errors
*/
-- CREATE TABLE
-- WEB_USER_CONTACT_PERMISSION
-- (
--         WEB_USER_ID     NUMBER  NOT NULL UNIQUE
--                              CONSTRAINT contperm_wbuserid_fk
--                              REFERENCES web_user(id)
--                              ON DELETE CASCADE,
--         EMAIL           CHAR(1) default 'N' check (email in ('Y','N')),
--         MAIL            CHAR(1) default 'N' check (mail in ('Y', 'N')),
--         CALL            CHAR(1) default 'N' check (call in ('Y', 'N')),
--         FAX             CHAR(1) default 'N' check (fax in ('Y', 'N')),
--         created         date            DEFAULT(sysdate),
--         modified        date            DEFAULT(sysdate)
-- );


--
-- Revision 1.5  2003/02/20 18:08:21  misa
-- bugzilla: none  Typo
--
-- Revision 1.4  2003/02/19 20:10:23  pjones
-- on delete cascade
--
-- Revision 1.3  2003/02/18 23:39:09  pjones
-- cascade deletes here
--
-- Revision 1.2  2002/05/09 06:24:49  gafton
-- unify
--
-- Revision 1.2  2002/02/13 00:50:40  misa
-- s/wucp./wucp_
--
-- Revision 1.1  2002/02/12 16:42:47  pjones
-- new for sat
--
