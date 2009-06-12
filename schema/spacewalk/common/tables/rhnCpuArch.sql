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


CREATE TABLE rhnCpuArch
(
    id        NUMBER NOT NULL,
    label     VARCHAR2(64) NOT NULL,
    name      VARCHAR2(64) NOT NULL,
    created   DATE
                  DEFAULT (sysdate) NOT NULL,
    modified  DATE
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_cpuarch_id_l_n_idx
    ON rhnCpuArch (id, label, name)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_cpuarch_l_id_n_idx
    ON rhnCpuArch (label, id, name)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_cpu_arch_id_seq START WITH 200;

ALTER TABLE rhnCpuArch
    ADD CONSTRAINT rhn_cpuarch_id_pk PRIMARY KEY (id);

ALTER TABLE rhnCpuArch
    ADD CONSTRAINT rhn_cpuarch_label_uq UNIQUE (label);

