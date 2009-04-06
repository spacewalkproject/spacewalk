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
-- misc user information and preferences

create table 
rhnUserInfo
(
        user_id		numeric
                        not null
                        constraint rhn_user_info_uid_uq unique
			constraint rhn_user_info_user_fk
                                references web_contact(id) on delete cascade,
	no_clear_sets	numeric default(0)
			not null,
	page_size	numeric default(20)
			not null,
	email_notify	numeric default(1)
			not null,
	bad_email	numeric default(0)
			not null,
	tz_offset       numeric default(-5)
	    	    	not null
			constraint rhn_user_info_tzoffset_ck
				check (tz_offset >= -11 and tz_offset <= 13),
	timezone_id     numeric
	    	    	not null
			constraint rhn_user_info_tzid_fk
				references rhnTimezone(id) on delete cascade,
	show_applied_errata
			char(1) default('N')
			not null
			constraint rhn_user_info_sea_ck check
				(show_applied_errata in ('Y','N')),
	show_system_group_list
			char(1) default('N')
			not null
			constraint rhn_user_info_ssgl_ck check
				(show_system_group_list in ('Y','N')),
	agreed_to_terms
			char(1) default('N')
			not null
			constraint rhn_user_info_agreed_ck check
				(agreed_to_terms in ('Y','N')),
	use_pam_authentication
			char(1) default('N')
			not null
			constraint rhn_user_info_pam_ck check
				(use_pam_authentication in ('Y','N')),
	last_logged_in 	date,
    	agreed_to_ws_terms
	                char(1)
                        constraint rhn_user_info_ws_ck check
			    (agreed_to_ws_terms is null or agreed_to_ws_terms in ('Y','N')),
    	agreed_to_es_terms
	    	    	char(1)
                        constraint rhn_user_info_es_ck check
			    (agreed_to_es_terms is null or agreed_to_es_terms in ('Y','N')),
      	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null,
        preferred_locale varchar(8)
)
  ;

create index rhn_user_info_uid_email_idx
	on rhnUserInfo ( user_id, email_notify )
  ;

--
-- Revision 1.30  2005/01/07 17:37:51  cturner
-- bugzilla: 144116.  yes, even though we don't use the columns, we should be consistent and have them in the db scripts til we drop them from dev/qa/stage/prod
--
-- Revision 1.29  2004/11/08 15:45:57  pjones
-- bugzilla: none -- triggers got moved to seperate file
--
-- Revision 1.28  2004/10/11 19:57:26  pjones
-- bugzilla: 134953 -- make the monitoring timezone data follow the rhnUserInfo
-- data
--
-- Revision 1.27  2004/09/27 19:16:34  cturner
-- first shot at timezone schema
--
-- Revision 1.26  2003/10/29 15:00:24  cturner
-- bugzilla: 106990, get rid of some unused columns and clear out agreed terms state
--
-- Revision 1.25  2003/04/29 15:16:11  pjones
-- clean up indexes we don't use.  The updates for this are in the
-- erratamail change for BEL
--
-- Revision 1.23  2003/03/11 00:21:58  pjones
-- add created/modified
--
-- Revision 1.22  2003/03/10 12:42:19  cturner
-- add WS and ES terms
--
-- Revision 1.21  2003/02/11 13:03:28  cturner
-- new column, last_logged_in for rhnUserInfo.  had a bogon in the table, email_last_verified.  no idea where it came from.  apparently I made it last October.  amazing.
--
-- Revision 1.20  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.19  2003/01/13 19:04:58  pjones
-- typos blow too
--
-- Revision 1.18  2003/01/13 18:59:09  pjones
-- asde license agreement
--
-- Revision 1.17  2003/01/13 16:50:14  pjones
-- revert this, it's part of rhnServer
--
-- Revision 1.16  2003/01/10 23:15:20  pjones
-- already in changes, needs to be here too
--
-- Revision 1.15  2002/10/22 19:59:20  rnorwood
-- SQL change for Toggle pref for system list/system group list
--
-- Revision 1.14  2002/10/22 05:15:53  cturner
-- add an email-last-verified column to rhnUserInfo
--
-- Revision 1.13  2002/06/21 03:33:25  cturner
-- pam field in rhnUserInfo
--
-- Revision 1.12  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
