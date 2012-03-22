--
-- Copyright (c) 2012 Red Hat, Inc.
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

CREATE TABLE rhnXccdfIdent
(
    id              NUMBER NOT NULL
                        CONSTRAINT rhn_xccdf_ident_id_pk PRIMARY KEY
                        USING INDEX TABLESPACE [[2m_tbs]],
    identsystem_id  NUMBER NOT NULL
                        CONSTRAINT rhn_xccdf_ident_system_fk
                            REFERENCES rhnXccdfIdentsystem (id),
    identifier      VARCHAR (100) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_xccdf_ident_isi_uq
    ON rhnXccdfIdent (identsystem_id, identifier)
    TABLESPACE [[2m_tbs]]
    NOLOGGING;

CREATE SEQUENCE rhn_xccdf_ident_id_seq;
