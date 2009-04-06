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


CREATE TABLE rhnServerInstallInfo
(
    id              NUMBER NOT NULL 
                        CONSTRAINT rhn_server_install_info_id_pk PRIMARY KEY 
                        USING INDEX TABLESPACE [[2m_tbs]], 
    server_id       NUMBER NOT NULL 
                        CONSTRAINT rhn_server_install_info_sid_fk
                            REFERENCES rhnServer (id), 
    install_method  VARCHAR2(32) NOT NULL, 
    iso_status      NUMBER, 
    mediasum        VARCHAR2(64), 
    created         DATE 
                        DEFAULT (sysdate) NOT NULL, 
    modified        DATE 
                        DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_s_inst_info_sid_im_idx
    ON rhnServerInstallInfo (server_id, install_method)
    TABLESPACE [[2m_tbs]];

CREATE UNIQUE INDEX rhn_server_install_info_sid_uq
    ON rhnServerInstallInfo (server_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_server_install_info_id_seq;

