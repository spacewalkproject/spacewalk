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
	id			numeric
				constraint rhn_ks_timezone_pk primary key
--				using index tablespace [[64k_tbs]]
                                ,
	label			varchar(128)
				not null,
	name			varchar(128)
				not null,
	install_type            numeric
				not null
				constraint rhn_ks_timezone_it_fk
				references rhnKSInstallType(id),
                                constraint rhn_ks_timezone_it_label_uq 
                                unique(install_type, label)
--                              using tablespace tablespace [[64k_tbs]]
                                ,
                                constraint rhn_ks_timezone_it_name_uq
                                unique(install_type, name)
--                              using undex tablespace [[64k_tbs]]
                                
)
  ;
	
