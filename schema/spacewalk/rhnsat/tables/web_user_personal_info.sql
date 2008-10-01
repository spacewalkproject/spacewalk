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
-- personal info about a contact
--
--
--

create table
web_user_personal_info
(
	web_user_id		number
				constraint wupi_wuid_nn not null
				constraint personal_info_web_user_id_fk
					references web_contact(id)
					on delete cascade,
	prefix			varchar(12) default ' '
				constraint wupi_prefix_nn not null
				constraint wupi_prefix_fk
					references web_user_prefix(text),
	first_names		varchar2(128)
				constraint wupi_fn_nn not null,
	last_name		varchar2(128)
				constraint wupi_ln_nn not null,
	genqual			varchar2(12),
	parent_company		varchar2(128),
	company			varchar2(128),
	title			varchar2(128),
	phone			varchar2(128),
	fax			varchar2(128),
	email			varchar2(128),
	email_uc		varchar2(128),
	pin			number,
	created			date default(sysdate)
				constraint wupi_created_nn not null,
	modified		date default(sysdate)
				constraint wupi_modified_nn not null,
	first_names_ol		varchar2(128),
	last_name_ol		varchar2(128),
	genqual_ol		varchar2(12),
	parent_company_ol	varchar2(128),
	company_ol		varchar2(128),
	title_ol		varchar2(128)
)
	enable row movement
	;

create or replace trigger
web_user_pi_timestamp
before insert or update on web_user_personal_info
for each row
begin
  :new.email_uc := upper(:new.email);
  :new.modified := sysdate;
end;
/
show errors

create index wupi_email_uc_idx
	on web_user_personal_info ( email_uc );

-- CREATE TABLE
-- WEB_USER_PERSONAL_INFO
-- (
--         WEB_USER_ID             NUMBER NOT NULL
--                                  CONSTRAINT personal_info_web_user_id_fk
--                                  REFERENCES web_contact(id)
--                                  ON DELETE CASCADE,
--         PREFIX                  VARCHAR(12) DEFAULT ' ' NOT NULL
--                                  CONSTRAINT personal_info_prefix_fk
--                                  REFERENCES web_user_prefix(text),
--         FIRST_NAMES             VARCHAR(128)    NOT NULL,
--         LAST_NAME               VARCHAR(128)    NOT NULL,
--         GENQUAL                 VARCHAR(12),   -- Jr., III, etc.; free text field.
--         PARENT_COMPANY          VARCHAR(128),
--         COMPANY                 VARCHAR(128),
--         TITLE                   VARCHAR(128),
--         PHONE                   VARCHAR(128),
--         FAX                     VARCHAR(128),
--         EMAIL                   VARCHAR(128),
--         PIN                     NUMBER,
--         created                 date            default(sysdate),
--         modified                date            default(sysdate),
--         first_names_ol varchar(128),
--         last_name_ol varchar(128),
--         genqual_ol varchar(12),
--         PARENT_COMPANY_OL VARCHAR2(128),
--         COMPANY_OL  VARCHAR2(128),
--         TITLE_OL VARCHAR2(128)
-- );

--
-- Revision 1.15  2005/02/23 19:57:08  jslagle
-- bz #147453
-- Will need to keep email_uc after all, and index.
-- RBO won't use idx on upper(email)
--
-- Revision 1.12  2003/02/20 17:42:13  misa
-- bugzilla: none  Typo
--
-- Revision 1.11  2003/02/19 20:10:23  pjones
-- on delete cascade
--
-- Revision 1.10  2003/02/18 23:39:09  pjones
-- cascade deletes here
--
-- Revision 1.9  2002/12/23 23:30:41  misa
-- Cut'n'paste error
--
-- Revision 1.8  2002/12/13 16:33:07  pjones
-- email_uc
--
-- Revision 1.7  2002/05/09 21:08:38  pjones
-- only for sat
--
-- Revision 1.6  2002/05/09 17:24:03  pjones
-- make this use prefix correctly, remove web_contact_triggers.satellite from
-- deps
--
-- Revision 1.5  2002/05/08 21:08:08  pjones
-- split this up
--
-- Revision 1.4  2002/02/13 15:52:38  pjones
-- missed one
--
-- Revision 1.3  2002/02/13 00:49:23  pjones
-- replace removed cols
--
-- Revision 1.2  2001/12/28 21:34:48  pjones
-- modified trigger
--
-- Revision 1.1  2001/12/28 21:23:42  pjones
-- this is all we're using in the schema directly; more will probably come
-- later.
--
