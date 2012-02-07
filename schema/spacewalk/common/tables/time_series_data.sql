--
-- Copyright (c) 2012 Red Hat, Inc.
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

create table time_series_data
(
    org_id      number not null,
    probe_id    number not null
                    constraint time_series_data_pid_fk references
                    time_series_purge(id),
    probe_desc  varchar2(64),
    entry_time  number not null,
    data        varchar2(1024)
)
enable row movement
;

create index time_series_data_pid_time_idx on time_series_data(probe_id, entry_time)
  tablespace [[64k_tbs]]
  nologging;
