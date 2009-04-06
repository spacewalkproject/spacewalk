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

-- this is an errata.  Still needs some work, methinks.
-- maybe take all the varchar2(4000) fields and make them references to a 
-- id -> clob map?
create table
rhnErrataTmp
(
        id              numeric
			not null
                        constraint rhn_erratatmp_id_pk primary key
--                      using index tablespace [[64k_tbs]]
                        ,
        advisory        varchar(37) -- advisory code
			not null 
                        constraint rhn_erratatmp_advisory_uq unique
--                      using index tablespace [[64k_tbs]]
                        ,
        advisory_type   varchar(32) -- plain text type of advisory
			not null
			constraint rhn_erratatmp_adv_type_ck
			check (advisory_type in ('Bug Fix Advisory',
			'Product Enhancement Advisory','Security Advisory')),
      	advisory_name	varchar(32)  -- advisory name and version
			not null
                        constraint rhn_erratatmp_advisory_name_uq unique
--                      using index tablespace [[64k_tbs]]
                        ,
	advisory_rel	numeric
			not null,
        product         varchar(64),
        description     varchar(4000), -- description
        synopsis        varchar(4000), -- Short description
        topic           varchar(4000), -- Problem description
                                      -- XXX: blob maybe - its all text
        solution        varchar(4000), -- how to resolve it
        issue_date      date default (current_date)
			not null,
        update_date     date default (current_date)
			not null,
        refers_to	varchar(4000),
        notes           varchar(4000),
        org_id          numeric
                        constraint rhn_erratatmp_oid_fk
                        references web_customer(id)
			on delete cascade,
       locally_modified char(1)
			constraint rhn_erratatmp_lm_ck check
			(locally_modified in ('Y','N')),
        created         date default (current_date)
			not null,
        modified        date default (current_date)
			not null,
       last_modified    date default (current_date)
                        not null

)
  ;

/*
create or replace trigger
rhn_erratatmp_mod_trig
before insert or update on rhnerratatmp
for each row
begin
        :new.modified := sysdate;
        :new.last_modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.9  2005/02/28 20:49:04  jslagle
-- bz #149470
-- Make product column varchar2(64) instead of varchar2(32)
--
-- Revision 1.8  2003/08/18 15:08:11  pjones
-- bugzilla: none
--
-- copy/paste error
--
-- Revision 1.7  2003/08/15 17:03:55  rnorwood
-- bugzilla: 101692 - add flow for cloning channels.
--
-- Revision 1.6  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/05/23 17:58:07  pjones
-- gdk says this stuff shouldn't be excluded now, so it isn't.
--
-- Revision 1.3  2002/05/09 20:52:41  pjones
-- these don't need get imported currently.
-- eventually, ResponsysUsers* should.
--
-- Revision 1.2  2002/05/09 04:47:07  gafton
-- exclude from satellite
--
-- Revision 1.1  2002/04/01 21:39:24  pjones
-- tmp errata tables
--
-- Revision 1.14  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.13  2002/02/22 22:07:20  cturner
-- put some constraints on this field that keeps acting funny
--
-- Revision 1.12  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.11  2001/12/27 18:22:01  pjones
-- policy change: foreign keys to other users' tables now _always_ go to
-- a synonym.  This makes satellite schema (where web_contact is in the same
-- namespace as rhn*) easier.
--

