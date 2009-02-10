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

create table rhnException
(
    id	        numeric not null
		constraint rhn_exc_id_pk primary key
--		    using index tablespace [[64k_tbs]],
    label       varchar(128) not null
		constraint rhn_exc_label_uq unique,
--		using tablespace [[64k_tbs]]
    message     varchar(2000) not null
)
  ;

--
-- Revision 1.12  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.11  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.10  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
--
-- Revision 1.9  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.8  2001/10/19 16:59:22  pjones
-- i _think_ this is right.  chip?
--
-- Revision 1.7  2001/10/04 21:49:42  pjones
-- for entitle_customer
--
-- Revision 1.6  2001/10/02 21:54:08  cturner
-- rhnChannelFamily and related changes.  should be complete, though not thoroughly tested
--
-- Revision 1.5  2001/07/09 17:23:07  cturner
-- prevent deletion of special ugroups/sgroups.  also improvement on channel editor package browsing
--
-- Revision 1.4  2001/07/04 02:08:52  cturner
-- trigger for making org admin the admin of all orgs.
--
-- Revision 1.3  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.2  2001/07/01 02:09:18  gafton
-- add id and log
--
