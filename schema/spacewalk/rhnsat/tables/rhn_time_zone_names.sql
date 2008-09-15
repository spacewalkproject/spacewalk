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
--$Id$
--
--

--reference table
--time_zone_names current prod row count = 23
create table 
rhn_time_zone_names
(
    recid                            number   (12)
        constraint rhn_tznms_recid_nn not null,
    java_id                          varchar2 (40)
        constraint rhn_tznms_java_id_nn not null
        constraint rhn_tznms_java_id_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    display_name                     varchar2 (60)
        constraint rhn_tznms_display_name_nn not null,
    gmt_offset_minutes               number   (4)
        constraint rhn_tznms_gmt_offset_nn not null,
    use_daylight_time                char     (1)
        constraint rhn_tznms_use_dst_nn not null,
    last_update_user                 varchar2 (40),
    last_update_date                 date
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_time_zone_names 
    is 'tznms  time zone names';

create unique index rhn_time_zone_names_uq 
    on rhn_time_zone_names ( display_name )
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_time_zone_names 
    add constraint rhn_time_zone_names_uq unique ( display_name );

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
