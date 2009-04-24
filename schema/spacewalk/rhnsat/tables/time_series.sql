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

create table
time_series
(
    o_id       varchar2(64)
    	       constraint time_series_o_id_nn not null,
    entry_time number
               constraint time_series_etime_nn not null,
    data       varchar2(1024)
)
    enable row movement
  ;
    
create index time_series_oid_entry_idx
    on time_series(o_id, entry_time)
    tablespace [[64k_tbs]]
  ;

create index time_series_probe_id_idx
on time_series(SUBSTR(O_ID, INSTR(O_ID, '-') + 1,
 (INSTR(O_ID, '-', INSTR(O_ID, '-') + 1) - INSTR(O_ID, '-')) - 1
 ))
tablespace [[64k_tbs]]
nologging;
