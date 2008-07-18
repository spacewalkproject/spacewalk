-- contact permission for a contact
--
-- $Id$

create table
web_user_contact_permission
(
	web_user_id		number
				constraint wucp_wuid_nn not null
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
	created			date default(sysdate)
				constraint wucp_created_nn not null,
	modified		date default(sysdate)
				constraint wucp_modified_nn not null
)
	enable row movement
	;

create or replace trigger
web_user_cp_timestamp
BEFORE INSERT OR UPDATE ON web_user_contact_permission
FOR EACH ROW
BEGIN
  :new.modified := sysdate;
END;
/
show errors

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


-- $Log$
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
