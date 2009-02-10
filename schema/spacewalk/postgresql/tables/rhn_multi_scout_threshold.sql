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

--originally from the nolog instance
--multi_scout_threshold current prod row count = 188
create table 
rhn_multi_scout_threshold
(
    probe_id                         numeric (12) not null
        constraint rhn_msthr_probe_id_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    scout_warning_threshold_is_all   char     (1)  default '1' not null,
    scout_crit_threshold_is_all      char     (1)  default '1' not null,
    scout_warning_threshold          numeric   (12),
    scout_critical_threshold         numeric   (12)
)
  ;

comment on table rhn_multi_scout_threshold 
    is 'msthr  multi_scout_threshold definitions';

--
--Revision 1.2  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
