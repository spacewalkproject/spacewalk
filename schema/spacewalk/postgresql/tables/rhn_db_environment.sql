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
--

--reference table
--db_environment current prod row count = 5
create table 
rhn_db_environment
(
    db_name     varchar (20) not null
        constraint rhn_dbenv_db_name_pk primary key
--            using index tablespace [[64k_tbs]]
            ,
    environment varchar (255)
		constraint rhn_dbenv_envir_environment_fk 
    		references rhn_environment( name )
)
  ;

comment on table rhn_db_environment 
    is 'dbenv environments - database_names xref';

--
--Revision 1.4  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.3  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.2  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--
--
--
