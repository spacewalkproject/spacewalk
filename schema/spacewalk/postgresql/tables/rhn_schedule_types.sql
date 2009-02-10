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
--schedule_types current prod row count = 3
create table 
rhn_schedule_types
(
    recid           numeric   (12) not null
        constraint rhn_schtp_recid_ck check (recid > 0)
        constraint rhn_schtp_recid_pk primary key
--            using index tablespace [[64k_tbs]]
            ,
    description     varchar (40)
)

  ;

comment on table rhn_schedule_types 
    is 'schtp  schedule types';

--create sequence rhn_schedule_types_recid_seq;

--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
