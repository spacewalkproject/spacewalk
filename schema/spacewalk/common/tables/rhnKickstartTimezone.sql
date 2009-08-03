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


CREATE TABLE rhnKickstartTimezone
(
    id            NUMBER NOT NULL
                      CONSTRAINT rhn_ks_timezone_pk PRIMARY KEY
                      USING INDEX TABLESPACE [[64k_tbs]],
    label         VARCHAR2(128) NOT NULL,
    name          VARCHAR2(128) NOT NULL,
    install_type  NUMBER NOT NULL
                      CONSTRAINT rhn_ks_timezone_it_fk
                          REFERENCES rhnKSInstallType (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_ks_timezone_it_label_uq
    ON rhnKickstartTimezone (install_type, label)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_ks_timezone_it_name_uq
    ON rhnKickstartTimezone (install_type, name)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_ks_timezone_id_seq;

