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

create table
rhnPackageFileDeleteQueue
(
        path            varchar2(1000),
	created			date default(sysdate)
				constraint rhn_pfdqueue_created_nn not null
)
	enable row movement
  ;

alter table rhnPackageFileDeleteQueue add constraint rhn_pfdqueue_path_uq
	unique ( path );

