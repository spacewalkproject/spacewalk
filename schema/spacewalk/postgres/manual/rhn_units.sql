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
--units current prod row count = 35
create table 
rhn_units
(
    unit_id             varchar(10)
                        not null
                        constraint rhn_units_unit_id_pk primary key
--                      using index tablespace [[64k_tbs]]
                        ,
    quantum_id          varchar (10)
                        not null
                        constraint rhn_units_qnta0_quantum_id_fk references rhn_quanta( quantum_id ),
    unit_label          varchar (20),
    description         varchar (200),
    to_base_unit_fn     varchar (2000),
    from_base_unit_fn   varchar (2000),
    validate_fn         varchar (2000),
    last_update_user    varchar (40),
    last_update_date    date
)
  
  ;

comment on table rhn_units 
    is 'units  unit definitions';

create index rhn_units_quantum_id_idx 
    on rhn_units ( quantum_id )
--    tablespace [[64k_tbs]]
  ;

--
--Revision 1.3  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
--
--
--
--
