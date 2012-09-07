--
-- Copyright (c) 2010--2012 Red Hat, Inc.
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


CREATE TABLE rhnPackageChangeLogData
(
    id          NUMBER NOT NULL
                    CONSTRAINT rhn_pkg_cld_id_pk PRIMARY KEY
                    USING INDEX TABLESPACE [[64k_tbs]],
    name        VARCHAR2(128) NOT NULL,
    text        VARCHAR2(3000) NOT NULL,
    time        timestamp with local time zone NOT NULL,
    created     timestamp with local time zone
                    DEFAULT (current_timestamp) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_pkg_cld_nt_idx
    ON rhnPackageChangeLogData (name, time)
    NOLOGGING
    TABLESPACE [[32m_tbs]];

CREATE SEQUENCE rhn_pkg_cld_id_seq;

