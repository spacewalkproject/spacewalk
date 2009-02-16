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
--time_zone_names current prod row count = 23
create table 
rhn_time_zone_names
(
    recid                            numeric(12)
                                     not null,
    java_id                          varchar(40)
                                     constraint rhn_tznms_java_id_pk primary key
--                                   using index tablespace [[64k_tbs]]
                                     ,
    display_name                     varchar(60)
                                     not null
                                     constraint rhn_time_zone_names_uq unique
--                                   using index tablespace [[64k_tbs]]
                                     ,
    gmt_offset_minutes               numeric(4)
                                     not null,
    use_daylight_time                char(1)
                                     not null,
    last_update_user                 varchar(40),
    last_update_date                 date
)
  ;

comment on table rhn_time_zone_names 
    is 'tznms  time zone names';

--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
