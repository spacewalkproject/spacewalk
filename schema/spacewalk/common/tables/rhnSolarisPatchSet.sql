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


CREATE TABLE rhnSolarisPatchSet
(
    package_id  NUMBER
                    CONSTRAINT rhn_solaris_ps_pid_pk PRIMARY KEY
                    CONSTRAINT rhn_solaris_ps_pid_fk
                        REFERENCES rhnPackage (id)
                        ON DELETE CASCADE,
    readme      BLOB,
    set_date    DATE
                    DEFAULT (sysdate) NOT NULL,
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[8m_data_tbs]]
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE rhn_solaris_ps_seq;

