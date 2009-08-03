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


CREATE TABLE rhn_multi_scout_threshold
(
    probe_id                        NUMBER(12) NOT NULL
                                        CONSTRAINT rhn_msthr_probe_id_pk PRIMARY KEY
                                        USING INDEX TABLESPACE [[2m_tbs]],
    scout_warning_threshold_is_all  CHAR(1)
                                        DEFAULT ('1') NOT NULL,
    scout_crit_threshold_is_all     CHAR(1)
                                        DEFAULT ('1') NOT NULL,
    scout_warning_threshold         NUMBER(12),
    scout_critical_threshold        NUMBER(12)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_multi_scout_threshold IS 'msthr  multi_scout_threshold definitions';

