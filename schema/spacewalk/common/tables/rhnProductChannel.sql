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


CREATE TABLE rhnProductChannel
(
    channel_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pc_cid_fk
                        REFERENCES rhnChannel (id)
                        ON DELETE CASCADE,
    product_id  NUMBER NOT NULL
                    CONSTRAINT rhn_pc_pid_fk
                        REFERENCES rhnProduct (id),
    created     DATE
                    DEFAULT (sysdate) NOT NULL,
    modified    DATE
                    DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_pc_cid_pid_idx
    ON rhnProductChannel (channel_id, product_id)
    TABLESPACE [[64k_tbs]];

CREATE INDEX rhn_pc_pid_cid_idx
    ON rhnProductChannel (product_id, channel_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhnProductChannel
    ADD CONSTRAINT rhn_pc_cid_pid_idx UNIQUE (channel_id, product_id);

