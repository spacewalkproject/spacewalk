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


CREATE TABLE rhnCpu
(
    id           NUMBER NOT NULL
                     CONSTRAINT rhn_cpu_id_pk PRIMARY KEY
                     USING INDEX TABLESPACE [[4m_tbs]],
    server_id    NUMBER NOT NULL
                     CONSTRAINT rhn_cpu_server_fk
                         REFERENCES rhnServer (id),
    cpu_arch_id  NUMBER NOT NULL
                     CONSTRAINT rhn_cpu_caid_fk
                         REFERENCES rhnCpuArch (id),
    bogomips     VARCHAR2(16),
    cache        VARCHAR2(16),
    family       VARCHAR2(32),
    MHz          VARCHAR2(16),
    stepping     VARCHAR2(16),
    flags        VARCHAR2(2048),
    model        VARCHAR2(64),
    version      VARCHAR2(32),
    vendor       VARCHAR2(32),
    nrcpu        NUMBER
                     DEFAULT (1),
    acpiVersion  VARCHAR2(64),
    apic         VARCHAR2(32),
    apmVersion   VARCHAR2(32),
    chipset      VARCHAR2(64),
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cpu_server_id_idx
    ON rhnCpu (server_id)
    TABLESPACE [[4m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_cpu_id_seq;

