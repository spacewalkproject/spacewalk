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


CREATE TABLE rhnGrailComponents
(
    id               NUMBER 
                         CONSTRAINT rhn_grail_comp_pk PRIMARY KEY 
                         USING INDEX TABLESPACE [[64k_tbs]], 
    component_pkg    VARCHAR2(64) NOT NULL, 
    component_mode   VARCHAR2(64) NOT NULL, 
    config_mode      VARCHAR2(64), 
    component_label  VARCHAR2(128), 
    role_required    NUMBER 
                         CONSTRAINT rhn_grail_comp_role_type_fk
                             REFERENCES rhnUserGroupType (id)
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_grail_comp_pkg_mode_uq
    ON rhnGrailComponents (component_pkg, component_mode)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_grail_comp_label_uq
    ON rhnGrailComponents (component_label)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_grail_components_seq;

