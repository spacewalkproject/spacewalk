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


CREATE TABLE rhnServerTokenRegs
(
    token_id   NUMBER NOT NULL 
                   CONSTRAINT rhn_srv_reg_tok_tid_fk
                       REFERENCES rhnRegToken (id) 
                       ON DELETE CASCADE, 
    server_id  NUMBER NOT NULL 
                   CONSTRAINT rhn_srv_reg_tok_sid_fk
                       REFERENCES rhnServer (id)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_srv_reg_tok_ts_idx
    ON rhnServerTokenRegs (token_id, server_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

CREATE INDEX RHN_SRVR_TKN_RGS_SID_TID_IDX
    ON rhnServerTokenRegs (server_id, token_id)
    TABLESPACE [[64k_tbs]]
    NOLOGGING;

