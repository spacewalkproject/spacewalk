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

-- User's addresses

create table
web_user_site_info
(
	id			number
				constraint wusi_id_nn not null
				constraint wusi_id_pk primary key,
	web_user_id		number
				constraint wusi_wuid_fk
					references web_contact(id)
					on delete cascade,
	email			varchar2(128),
	email_uc		varchar2(128),
	alt_first_names		varchar2(128),
	alt_last_name		varchar2(128),
	address1		varchar2(128)
				constraint wusi_addr1_nn not null,
	address2		varchar2(128),
	address3		varchar2(128),
	address4		varchar2(128),
	city			varchar2(128)
				constraint wusi_city_nn not null,
	state			varchar2(64),
	zip			varchar2(64),
	country			char(2)
				constraint wusi_country_nn not null,
	phone			varchar2(32),
	fax			varchar2(32),
	url			varchar2(128),
	is_po_box		char(1) default '0'
				constraint wusi_ipb_ck
					check (is_po_box in ('1','0')),
	type			char(1)
				constraint wusi_type_fk
					references web_user_site_type(type),
	oracle_site_id		varchar2(32),
	notes			varchar2(2000),
	created			date default(sysdate),
	modified		date default(sysdate),
	alt_first_names_ol	varchar2(128),
	alt_last_name_ol	varchar2(128),
	address1_ol		varchar2(128),
	address2_ol		varchar2(128),
	address3_ol		varchar2(128),
	city_ol			varchar2(128),
	state_ol		varchar2(32),
	zip_ol			varchar2(32)
)
	enable row movement
	;

create sequence web_user_site_info_id_seq;

create index web_user_site_info_wuid 
    on web_user_site_info(web_user_id)
create index wusi_email_uc_idx
    on web_user_site_info ( email_uc );

create or replace trigger
web_user_si_timestamp
before insert or update on web_user_site_info
for each row
begin
  :new.email_uc := upper(:new.email);
  :new.modified := sysdate;
end;
/
show errors

--
-- Revision 1.5  2003/02/20 17:44:17  misa
-- bugzilla: none  Typo
--
-- Revision 1.4  2003/02/18 23:39:09  pjones
-- cascade deletes here
--
-- Revision 1.3  2002/12/13 16:33:07  pjones
-- email_uc
--
-- Revision 1.2  2002/05/09 05:45:24  gafton
-- unify again
--
-- Revision 1.3  2002/02/22 15:24:24  pjones
-- missed address2_ol .  oops.
--
-- Revision 1.2  2002/02/19 18:55:48  pjones
-- add sequence
--
-- Revision 1.1  2002/02/13 16:20:43  pjones
-- commit these here
--
