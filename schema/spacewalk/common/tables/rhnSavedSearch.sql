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


CREATE TABLE rhnSavedSearch
(
    id              NUMBER NOT NULL,
    web_contact_id  NUMBER NOT NULL
                        CONSTRAINT rhn_savedsearch_wcid_fk
                            REFERENCES web_contact (id)
                            ON DELETE CASCADE,
    name            VARCHAR2(16) NOT NULL,
    type            NUMBER NOT NULL
                        CONSTRAINT rhn_savedsearch_type_fk
                            REFERENCES rhnSavedSearchType (id),
    search_string   VARCHAR2(4000) NOT NULL,
    search_set      VARCHAR2(16) NOT NULL
                        CONSTRAINT rhn_savedsearch_sset_ck
                            CHECK (search_set in ( 'all' , 'system_list' )),
    search_field    VARCHAR2(128) NOT NULL,
    invert          CHAR
                        DEFAULT ('N') NOT NULL
                        CONSTRAINT rhn_savedsearch_invert_ck
                            CHECK (invert in ( 'Y' , 'N' ))
)
ENABLE ROW MOVEMENT
;

CREATE INDEX rhn_savedsearch_id_wcid_idx
    ON rhnSavedSearch (id, web_contact_id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_savedsearch_wcid_id_idx
    ON rhnSavedSearch (web_contact_id, id)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_savedsearch_name_wcid_idx
    ON rhnSavedSearch (name, web_contact_id)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_savedsearch_id_seq;

ALTER TABLE rhnSavedSearch
    ADD CONSTRAINT rhn_savedsearch_id_pk PRIMARY KEY (id);

ALTER TABLE rhnSavedSearch
    ADD CONSTRAINT rhn_savedsearch_name_wcid_uq UNIQUE (name, web_contact_id);

