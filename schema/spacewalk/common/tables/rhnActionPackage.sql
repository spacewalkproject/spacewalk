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


CREATE TABLE rhnActionPackage
(
    id               NUMBER NOT NULL 
                         CONSTRAINT rhn_act_p_id_pk PRIMARY KEY 
                         USING INDEX TABLESPACE [[8m_tbs]], 
    action_id        NUMBER NOT NULL 
                         CONSTRAINT rhn_act_p_act_fk
                             REFERENCES rhnAction (id) 
                             ON DELETE CASCADE, 
    parameter        VARCHAR2(128) 
                         DEFAULT ('upgrade') NOT NULL 
                         CONSTRAINT rhn_act_p_param_ck
                             CHECK (parameter IN ( 'upgrade' , 'install' , 'remove' , 'downgrade' )), 
    name_id          NUMBER NOT NULL 
                         CONSTRAINT rhn_act_p_name_fk
                             REFERENCES rhnPackageName (id), 
    evr_id           NUMBER 
                         CONSTRAINT rhn_act_p_evr_fk
                             REFERENCES rhnPackageEvr (id), 
    package_arch_id  NUMBER 
                         CONSTRAINT rhn_act_p_paid_fk
                             REFERENCES rhnPackageArch (id)
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_act_p_aid_idx
    ON rhnActionPackage (action_id)
    TABLESPACE [[4m_tbs]]
    LOGGING;

CREATE SEQUENCE rhn_act_p_id_seq;

