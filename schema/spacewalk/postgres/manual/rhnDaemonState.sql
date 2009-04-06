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
-- this keeps track of when any of the daemons which run against the db
-- were last executed

create table
rhnDaemonState
(
	label		varchar(64)
			not null
			constraint rhn_daemonstate_label_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	last_poll	date
			not null
)
  ;

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2003/01/13 21:47:31  pjones
-- and spell it sanely
--
