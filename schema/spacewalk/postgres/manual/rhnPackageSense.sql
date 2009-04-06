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
rhnPackageSense
(
	id		numeric
			constraint rhn_pkg_sense_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	label		varchar(32)
			not null
                        constraint rhn_pkg_sense_label_uq unique
--                      using index tablespace [[64k_tbs]]
)
  ;

--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.6  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
