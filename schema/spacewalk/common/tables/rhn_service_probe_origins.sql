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


CREATE TABLE rhn_service_probe_origins
(
    service_probe_id  NUMBER(12) NOT NULL,
    origin_probe_id   NUMBER(12),
    decoupled         CHAR(1)
                          DEFAULT ('0') NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_service_probe_origins IS 'srvpo  mapping from a replicated service probe to the check suite probe it was copied from.  uq instead of pk because need to set origin_probe_id to null!!!';

CREATE UNIQUE INDEX rhn_srvpo_serv_pr_id_orig_uq
    ON rhn_service_probe_origins (service_probe_id, origin_probe_id)
    TABLESPACE [[8m_tbs]];

CREATE UNIQUE INDEX rhn_srvpo_serv_orig_pr_id_uq
    ON rhn_service_probe_origins (origin_probe_id, service_probe_id)
    TABLESPACE [[8m_tbs]];

ALTER TABLE rhn_service_probe_origins
    ADD CONSTRAINT rhn_srvpo_serv_pr_id_orig_uq UNIQUE (service_probe_id, origin_probe_id);

ALTER TABLE rhn_service_probe_origins
    ADD CONSTRAINT rhn_srvpo_chkpb_orig_pr_id_fk FOREIGN KEY (origin_probe_id)
    REFERENCES rhn_check_suite_probe (probe_id)
        ON DELETE CASCADE;

ALTER TABLE rhn_service_probe_origins
    ADD CONSTRAINT rhn_srvpo_pr_serv_pr_fk FOREIGN KEY (service_probe_id)
    REFERENCES rhn_probe (recid)
        ON DELETE CASCADE;

