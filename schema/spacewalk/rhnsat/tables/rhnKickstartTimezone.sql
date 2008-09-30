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
rhnKickstartTimezone
(
	id			number
				constraint rhn_ks_timezone_id_nn not null
				constraint rhn_ks_timezone_pk primary key
					using index tablespace [[64k_tbs]],
	label			varchar2(128)
				constraint rhn_ks_timezone_label_nn not null,
	name			varchar2(128)
				constraint rhn_ks_timezone_name_nn not null,
	install_type            number
				constraint rhn_ks_timezone_it_nn not null
				constraint rhn_ks_timezone_it_fk
				    references rhnKSInstallType(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;
	
create sequence rhn_ks_timezone_id_seq;
	
create unique index rhn_ks_timezone_it_label_uq
	on rhnKickstartTimezone(install_type, label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;
create unique index rhn_ks_timezone_it_name_uq
	on rhnKickstartTimezone(install_type, name)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

--
