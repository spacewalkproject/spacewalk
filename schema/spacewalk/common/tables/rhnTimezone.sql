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


CREATE TABLE rhnTimezone
(
    id            NUMBER NOT NULL, 
    olson_name    VARCHAR2(128) NOT NULL, 
    display_name  VARCHAR2(128) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_timezone_id_idx
    ON rhnTimezone (id)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_timezone_olson_uq
    ON rhnTimezone (olson_name);

CREATE UNIQUE INDEX rhn_timezone_display_uq
    ON rhnTimezone (display_name);

CREATE SEQUENCE rhn_timezone_id_seq START WITH 7000 ORDER;

ALTER TABLE rhnTimezone
    ADD CONSTRAINT rhn_timezone_id_pk PRIMARY KEY (id);

