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
--quanta current prod row count = 13
create table 
rhn_quanta
(
    quantum_id          varchar2 (10)
        constraint rhn_qnta0_quantum_id_nn not null
        constraint rhn_qnta0_quantum_id_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    basic_unit_id       varchar2 (20),
    description         varchar2 (200),
    last_update_user    varchar2 (40),
    last_update_date    date
) 
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_quanta 
    is 'qnta0  quanta definitions';

--$Log$
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
