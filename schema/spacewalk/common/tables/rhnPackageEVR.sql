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


CREATE TABLE rhnPackageEVR
(
    id       NUMBER NOT NULL 
                 CONSTRAINT rhn_pe_id_pk PRIMARY KEY, 
    epoch    VARCHAR2(16), 
    version  VARCHAR2(512) NOT NULL, 
    release  VARCHAR2(512) NOT NULL, 
    evr      EVR_T NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_pe_v_r_e_uq
    ON rhnPackageEVR (version, release, epoch)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_pkg_evr_seq;

