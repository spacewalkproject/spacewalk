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

-- this matches errata <-> bugzilla bugs, possibly many to many (?)
create table
rhnErrataBuglist
(
	errata_id	numeric
			not null
			constraint rhn_errata_buglist_errata_fk
			references rhnErrata(id)
			on delete cascade,
	bug_id		numeric
			not null,
			-- XXX: this is really an FK
			-- XXX  to bugzilla
	summary		varchar(4000),
	created		date default (current_date)
			not null,
	modified	date default (current_date)
			not null,
                        constraint rhn_err_bug_list_uq
                        unique(errata_Id,bug_Id)
--                      using index tablespace [[64k_tbs]]
)
  ;

/*
create or replace trigger
rhn_errata_buglist_mod_trig
before insert or update on rhnErrataBuglist
for each row
begin
	:new.modified := sysdate;
end rhn_errata_buglist_mod_trig;
/
show errors
*/

--
-- Revision 1.12  2004/12/07 23:17:01  misa
-- bugzilla: 141768  Dropping some unused triggers
--
-- Revision 1.11  2004/10/29 18:11:45  pjones
-- bugzilla: 137474 -- triggers to maintain last_modified everywhere
--
-- Revision 1.10  2003/08/14 20:01:13  pjones
-- bugzilla: 102263
--
-- delete cascades on rhnErrata and rhnErrataTmp where applicable
--
-- Revision 1.9  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.8  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.7  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.6  2001/07/05 19:49:04  pjones
-- rename unique index appropriately
--
-- Revision 1.5  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.4  2001/07/01 06:16:56  gafton
-- named constraints, dammit.
--
-- Revision 1.3  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.2  2001/06/27 02:18:12  pjones
-- triggers
--
-- Revision 1.1  2001/06/27 01:46:05  pjones
-- initial checkin
