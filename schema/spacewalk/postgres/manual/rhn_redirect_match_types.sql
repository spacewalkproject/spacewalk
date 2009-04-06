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
--redirect_match_types current prod row count = 10
create table 
rhn_redirect_match_types
(
    name                varchar(255) not null
        constraint rhn_rdrmt_name_pk primary key
--            using index tablespace [[64k_tbs]]
)
;

comment on table rhn_redirect_match_types 
    is 'rdrmt  redirect match types';

--
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
