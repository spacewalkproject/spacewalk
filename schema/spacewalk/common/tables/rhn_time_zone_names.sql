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


CREATE TABLE rhn_time_zone_names
(
    recid               NUMBER(12) NOT NULL,
    java_id             VARCHAR2(40) NOT NULL
                            CONSTRAINT rhn_tznms_java_id_pk PRIMARY KEY
                            USING INDEX TABLESPACE [[64k_tbs]],
    display_name        VARCHAR2(60) NOT NULL,
    gmt_offset_minutes  NUMBER(4) NOT NULL,
    use_daylight_time   CHAR(1) NOT NULL,
    last_update_user    VARCHAR2(40),
    last_update_date    DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_time_zone_names IS 'tznms  time zone names';

CREATE UNIQUE INDEX rhn_time_zone_names_uq
    ON rhn_time_zone_names (display_name)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhn_time_zone_names
    ADD CONSTRAINT rhn_time_zone_names_uq UNIQUE (display_name);

