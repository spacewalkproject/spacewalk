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

--physical_location current prod row count = 189
create table 
rhn_physical_location
(
    recid               numeric   (12) not null
        constraint rhn_phslc_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    location_name       varchar (40),
    address1            varchar (255),
    address2            varchar (255),
    city                varchar (128),
    state               varchar (128),
    country             varchar (2),
    zipcode             varchar (10),
    phone               varchar (40),
    deleted             char     (1),
    last_update_user    varchar (40),
    last_update_date    date,
    customer_id         numeric   (12)  default 999 not null
)
  ;

comment on table rhn_physical_location 
    is 'phslc  physical location records';

--NOTE: Had to shorten sequence name
create sequence rhn_physical_loc_recid_seq;
