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
rhnActionType
(
	id			number
				constraint rhn_action_type_id_nn not null
				constraint rhn_action_type_pk primary key
					using index tablespace [[64k_tbs]],
	label			varchar2(48)
				constraint rhn_action_type_label_nn not null,
	name			varchar2(100)
				constraint rhn_action_type_name_nn not null,
	trigger_snapshot	char(1) default('N')
				constraint rhn_action_type_trigsnap_nn not null
				constraint rhn_action_type_trigsnap_ck
					check (trigger_snapshot in ('Y','N')),
	unlocked_only   	char(1) default('N')
				constraint rhn_action_type_unlck_nn not null
				constraint rhn_action_type_unlck_ck
					check (unlocked_only in ('Y','N'))
)
	storage ( freelists 16 )
	initrans 32;
	
create unique index rhn_action_type_label_uq
	on rhnActionType(label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_action_type_name_uq
	on rhnActionType(name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.19  2003/10/23 18:37:55  misa
-- MIssing comma
--
-- Revision 1.18  2003/10/23 17:42:00  cturner
-- add unlocked_only column to rhnactiontype, and set to appropriate values
--
-- Revision 1.17  2003/09/18 14:32:02  pjones
-- bugzilla: none
--
-- typo fix
--
-- Revision 1.16  2003/09/17 19:50:21  pjones
-- bugzilla: 103957
--
-- "trigger_snapshot" on rhnActionType
--
-- Revision 1.15  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.14  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
