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
rhnChannelFamily
(
	id		numeric not null
			constraint rhn_channel_family_id_pk primary key,
--				using index tablespace [[64k_tbs]],
	org_id		numeric 
			constraint rhn_channel_family_org_fk
				references web_customer(id)
				on delete cascade,
	name		varchar(128) not null
			constraint rhn_channel_family_name_uq unique,
--			using tablespace [[64k_tbs]]
	label		varchar(128) not null
			constraint rhn_channel_family_label_uq unique,
--			using tablespace [[64k_tbs]]
	product_url     varchar(128) default 'http://www.redhat.com/products/' not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
;

create sequence rhn_channel_family_id_seq start with 1000;

--create or replace trigger
--rhn_channel_family_mod_trig
--before insert or update on rhnChannelFamily
--for each row
--begin
--	:new.modified := sysdate;
--end;
--/
--show errors

--
-- Revision 1.20  2003/04/11 20:46:21  cturner
-- bugzilla: 85923.  begone purchasable flag
--
-- Revision 1.19  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2002/03/19 22:41:30  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.16  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
