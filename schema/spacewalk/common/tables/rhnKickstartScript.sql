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


CREATE TABLE rhnKickstartScript
(
    id            NUMBER NOT NULL, 
    kickstart_id  NUMBER NOT NULL 
                      CONSTRAINT rhn_ksscript_ksid_fk
                          REFERENCES rhnKSData (id) 
                          ON DELETE CASCADE, 
    position      NUMBER NOT NULL, 
    script_type   VARCHAR2(4) NOT NULL 
                      CONSTRAINT rhn_ksscript_st_ck
                          CHECK (script_type in ( 'pre' , 'post' )), 
    chroot        CHAR(1) 
                      DEFAULT ('Y') NOT NULL 
                      CONSTRAINT rhn_ksscript_chroot_ck
                          CHECK (chroot in ( 'Y' , 'N' )), 
    raw_script    CHAR(1)
                      DEFAULT ('Y') NOT NULL
                      CONSTRAINT rhn_ksscript_rawscript_ck
                          CHECK (raw_script in ('Y','N')),
    interpreter   VARCHAR2(80), 
    data          BLOB, 
    created       DATE 
                      DEFAULT (sysdate) NOT NULL, 
    modified      DATE 
                      DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_ksscript_id_idx
    ON rhnKickstartScript (id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_ksscript_ksid_pos_idx
    ON rhnKickstartScript (kickstart_id, position)
    TABLESPACE [[8m_tbs]];

CREATE SEQUENCE rhn_ksscript_id_seq;

ALTER TABLE rhnKickstartScript
    ADD CONSTRAINT rhn_ksscript_id_pk PRIMARY KEY (id);

ALTER TABLE rhnKickstartScript
    ADD CONSTRAINT rhn_ksscript_ksid_pos_uq UNIQUE (kickstart_id, position);

