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


CREATE TABLE rhnPackageKey
(
    id           NUMBER NOT NULL,
    key_id       VARCHAR2(64) NOT NULL,
    key_type_id  NUMBER NOT NULL
                     CONSTRAINT rhn_pkey_type_id_prid_fk
                         REFERENCES rhnPackageKeyType (id),
    provider_id  NUMBER
                     CONSTRAINT rhn_pkey_prid_fk
                         REFERENCES rhnPackageProvider (id),
    created      DATE
                     DEFAULT (sysdate) NOT NULL,
    modified     DATE
                     DEFAULT (sysdate) NOT NULL
)
;

CREATE SEQUENCE rhn_pkey_id_seq START WITH 100;

ALTER TABLE rhnPackageKey
    ADD CONSTRAINT rhn_pkey_id_pk PRIMARY KEY (id);

ALTER TABLE rhnPackageKey
    ADD CONSTRAINT rhn_pkey_keyid_uq UNIQUE (key_id);

