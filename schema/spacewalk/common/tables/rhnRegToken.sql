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


CREATE TABLE rhnRegToken
(
    id              NUMBER NOT NULL 
                        CONSTRAINT rhn_reg_token_pk PRIMARY KEY, 
    org_id          NUMBER NOT NULL 
                        CONSTRAINT rhn_reg_token_oid_fk
                            REFERENCES web_customer (id) 
                            ON DELETE CASCADE, 
    user_id         NUMBER 
                        CONSTRAINT rhn_reg_token_uid_fk
                            REFERENCES web_contact (id) 
                            ON DELETE SET NULL, 
    server_id       NUMBER 
                        CONSTRAINT rhn_reg_token_sid_fk
                            REFERENCES rhnServer (id), 
    note            VARCHAR2(2048) NOT NULL, 
    usage_limit     NUMBER 
                        DEFAULT (0), 
    disabled        NUMBER 
                        DEFAULT (0) NOT NULL, 
    deploy_configs  CHAR(1) 
                        DEFAULT ('Y') NOT NULL 
                        CONSTRAINT rhn_reg_token_deployconfs_ck
                            CHECK (deploy_configs in ( 'Y' , 'N' ))
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_reg_token_org_id_idx
    ON rhnRegToken (org_id, id)
    TABLESPACE [[64k_tbs]]
    LOGGING;

CREATE INDEX rhn_reg_token_uid_idx
    ON rhnRegToken (user_id)
    TABLESPACE [[64k_tbs]]
    LOGGING;

CREATE INDEX rhn_reg_token_sid_idx
    ON rhnRegToken (server_id)
    TABLESPACE [[8m_tbs]]
    LOGGING;

CREATE SEQUENCE rhn_reg_token_seq;

