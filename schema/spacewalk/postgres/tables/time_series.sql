-- oracle equivalent source sha1 a67701be270afd89aa457bffa73e67220020b57e
-- retrieved from ./1242148739/5b0d12b97e5fd08c735eda344779d685aebd6409/schema/spacewalk/oracle/tables/time_series.sql
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

CREATE TABLE time_series
(
    o_id        VARCHAR(64) NOT NULL, 
    entry_time  NUMERIC NOT NULL, 
    data        VARCHAR(1024)
)
;

CREATE INDEX time_series_probe_id_idx
  ON time_series(substring(o_id FROM position('-' IN o_id) + 1
                            FOR position('-' IN substring(o_id FROM position('-' IN o_id) + 1)) - 1));

CREATE INDEX time_series_oid_entry_idx
    ON time_series (o_id, entry_time)
;

