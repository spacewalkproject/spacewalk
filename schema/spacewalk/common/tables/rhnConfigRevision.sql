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


CREATE TABLE rhnConfigRevision
(
    id                   NUMBER NOT NULL
                             CONSTRAINT rhn_confrevision_id_pk PRIMARY KEY
                             USING INDEX TABLESPACE [[4m_tbs]],
    revision             NUMBER NOT NULL,
    config_file_id       NUMBER NOT NULL
                             CONSTRAINT rhn_confrevision_cfid_fk
                                 REFERENCES rhnConfigFile (id),
    config_content_id    NUMBER 
                             CONSTRAINT rhn_confrevision_ccid_fk
                                 REFERENCES rhnConfigContent (id),
    config_info_id       NUMBER NOT NULL
                             CONSTRAINT rhn_confrevision_ciid_fk
                                 REFERENCES rhnConfigInfo (id),
    created              DATE
                             DEFAULT (sysdate) NOT NULL,
    modified             DATE
                             DEFAULT (sysdate) NOT NULL,
    config_file_type_id  NUMBER
                             DEFAULT (1) NOT NULL
                             CONSTRAINT rhn_conf_rev_cfti_fk
                                 REFERENCES rhnConfigFileType (id),
    changed_by_id        NUMBER
                             DEFAULT (null)
                             CONSTRAINT rhn_confrevision_cid_fk
                                 REFERENCES web_contact (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_confrevision_cfid_rev_uq
    ON rhnConfigRevision (config_file_id, revision)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_confrevision_id_seq;

