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


CREATE TABLE rhn_notification_formats
(
    recid               NUMBER NOT NULL
                            CONSTRAINT rhn_ntfmt_recid_pk PRIMARY KEY
                            USING INDEX TABLESPACE [[64k_tbs]],
    customer_id         NUMBER,
    description         VARCHAR2(255) NOT NULL,
    subject_format      VARCHAR2(4000),
    body_format         VARCHAR2(4000) NOT NULL,
    max_subject_length  NUMBER,
    max_body_length     NUMBER
                            DEFAULT (1920) NOT NULL,
    reply_format        VARCHAR2(4000)
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_notification_formats IS 'ntfmt  notification message formats';

CREATE INDEX rhn_ntfmt_customer_idx
    ON rhn_notification_formats (customer_id)
    TABLESPACE [[64k_tbs]];

CREATE SEQUENCE rhn_ntfmt_recid_seq;

ALTER TABLE rhn_notification_formats
    ADD CONSTRAINT rhn_ntfmt_customer_fk FOREIGN KEY (customer_id)
    REFERENCES web_customer (id);

