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


CREATE TABLE rhnActionPackageAnswerfile
(
    action_package_id  NUMBER NOT NULL
                           CONSTRAINT rhn_act_p_af_apid_fk
                               REFERENCES rhnActionPackage (id)
                               ON DELETE CASCADE,
    answerfile         BLOB,
    created            DATE
                           DEFAULT (sysdate) NOT NULL,
    modified           DATE
                           DEFAULT (sysdate) NOT NULL
)
TABLESPACE [[blob]]
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_act_p_af_aid_idx
    ON rhnActionPackageAnswerfile (action_package_id)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

