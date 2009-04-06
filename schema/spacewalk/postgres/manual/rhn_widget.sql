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
--widget current prod row count = 3
create table 
rhn_widget
( 
    name                varchar (20) not null
        constraint rhn_wdget_name_pk primary key
--            using index tablespace [[64k_tbs]]
            ,
    description         varchar (80) not null,
    last_update_user    varchar (40),
    last_update_date    date         
) 
  ;

comment on table rhn_widget 
    is 'wdget  text,password,menu,radio,checkbox';

--
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
