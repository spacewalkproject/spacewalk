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

--pager_types current prod row count = 582
create table 
rhn_pager_types
(
    recid           numeric   (12) not null
        constraint rhn_pgrtp_recid_ck check (recid > 0)
        constraint rhn_pgrtp_recid_pk primary key,
--            using index tablespace [[2m_tbs]]
            
    pager_type_name varchar (50)
)
  ;

comment on table rhn_pager_types 
    is 'pgrtp  pager types';

create sequence rhn_pager_types_recid_seq;

--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
