--
-- Copyright (c) 2012 Novell
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

CREATE TABLE suseCredentialsType
(
    id        NUMBER NOT NULL
                  CONSTRAINT suse_credtype_id_pk PRIMARY KEY
                  USING INDEX TABLESPACE [[64k_tbs]],
    label     VARCHAR2(64) NOT NULL,
    name      VARCHAR2(128) NOT NULL,
    created   DATE
                  DEFAULT (sysdate) NOT NULL,
    modified  DATE
                  DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE INDEX suse_credtype_label_id_idx
    ON suseCredentialsType (label, id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE suse_credtype_id_seq;

ALTER TABLE suseCredentialsType
    ADD CONSTRAINT suse_credtype_label_uq UNIQUE (label);
