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
rhnActionType
(
	id			numeric not null
				constraint rhn_action_type_pk primary key
--					using index tablespace [[64k_tbs]]
					,
	label			varchar(48) not null
				constraint rhn_action_type_label_uq unique
--					using index tablespace [[64k_tbs]]
					,
	name			varchar(100) not null
				constraint rhn_action_type_name_uq unique
--					using index tablespace [[64k_tbs]]
					,
	trigger_snapshot	char(1) default('N') not null
				constraint rhn_action_type_trigsnap_ck
					check (trigger_snapshot in ('Y','N')),
	unlocked_only   	char(1) default('N') not null
				constraint rhn_action_type_unlck_ck
					check (unlocked_only in ('Y','N'))

);

