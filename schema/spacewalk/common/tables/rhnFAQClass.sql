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


CREATE TABLE rhnFAQClass
(
    id        NUMBER NOT NULL
                  CONSTRAINT rhn_faq_class_id_pk PRIMARY KEY
                  USING INDEX TABLESPACE [[64k_tbs]],
    name      VARCHAR2(128),
    label     VARCHAR2(32) NOT NULL,
    ordering  NUMBER NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE UNIQUE INDEX rhn_faqclass_label_uq
    ON rhnFAQClass (label)
    TABLESPACE [[64k_tbs]];

CREATE UNIQUE INDEX rhn_faqclass_or_uq
    ON rhnFAQClass (ordering)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE RHN_FAQ_CLASS_ID_SEQ START WITH 101;

