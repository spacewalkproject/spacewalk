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


CREATE TABLE rhnTinyURL
(
    token    VARCHAR2(64) NOT NULL, 
    url      VARCHAR2(512) NOT NULL, 
    enabled  VARCHAR2(1) NOT NULL 
                 CONSTRAINT rhn_tu_enabled_ck
                     CHECK (enabled in ( 'Y' , 'N' )), 
    created  DATE 
                 DEFAULT (sysdate) NOT NULL, 
    expires  DATE 
                 DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_tu_token_uq
    ON rhnTinyURL (token)
    TABLESPACE [[2m_tbs]];

