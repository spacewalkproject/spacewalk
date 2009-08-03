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


CREATE TABLE rhn_redirect_email_targets
(
    redirect_id    NUMBER(12) NOT NULL,
    email_address  VARCHAR2(255) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_redirect_email_targets IS 'rdret  redirect email targets';

CREATE UNIQUE INDEX rhn_rdret_pk
    ON rhn_redirect_email_targets (redirect_id, email_address)
    TABLESPACE [[2m_tbs]];

CREATE INDEX rhn_rdret_redirect_id_idx
    ON rhn_redirect_email_targets (redirect_id)
    TABLESPACE [[2m_tbs]];

ALTER TABLE rhn_redirect_email_targets
    ADD CONSTRAINT rhn_rdret_pk PRIMARY KEY (redirect_id, email_address);

ALTER TABLE rhn_redirect_email_targets
    ADD CONSTRAINT rhn_rdret_rdrct_redirect_id_fk FOREIGN KEY (redirect_id)
    REFERENCES rhn_redirects (recid)
        ON DELETE CASCADE;

