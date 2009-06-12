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


CREATE TABLE rhnErrataTmp
(
    id                NUMBER NOT NULL
                          CONSTRAINT rhn_erratatmp_id_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[64k_tbs]],
    advisory          VARCHAR2(37) NOT NULL,
    advisory_type     VARCHAR2(32) NOT NULL
                          CONSTRAINT rhn_erratatmp_adv_type_ck
                              CHECK (advisory_type in ( 'Bug Fix Advisory' , 'Product Enhancement Advisory' , 'Security Advisory' )),
    advisory_name     VARCHAR2(32) NOT NULL,
    advisory_rel      NUMBER NOT NULL,
    product           VARCHAR2(64),
    description       VARCHAR2(4000),
    synopsis          VARCHAR2(4000),
    topic             VARCHAR2(4000),
    solution          VARCHAR2(4000),
    issue_date        DATE
                          DEFAULT (sysdate) NOT NULL,
    update_date       DATE
                          DEFAULT (sysdate) NOT NULL,
    refers_to         VARCHAR2(4000),
    notes             VARCHAR2(4000),
    org_id            NUMBER
                          CONSTRAINT rhn_erratatmp_oid_fk
                              REFERENCES web_customer (id)
                              ON DELETE CASCADE,
    locally_modified  CHAR(1)
                          CONSTRAINT rhn_erratatmp_lm_ck
                              CHECK (locally_modified in ( 'Y' , 'N' )),
    created           DATE
                          DEFAULT (sysdate) NOT NULL,
    modified          DATE
                          DEFAULT (sysdate) NOT NULL,
    last_modified     DATE
                          DEFAULT (sysdate) NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_erratatmp_advisory_uq
    ON rhnerratatmp (advisory)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_erratatmp_advisory_name_uq
    ON rhnerratatmp (advisory_name)
    TABLESPACE [[64k_tbs]];

