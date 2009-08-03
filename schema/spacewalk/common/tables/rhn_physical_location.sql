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


CREATE TABLE rhn_physical_location
(
    recid             NUMBER(12) NOT NULL
                          CONSTRAINT rhn_phslc_recid_pk PRIMARY KEY
                          USING INDEX TABLESPACE [[2m_tbs]],
    location_name     VARCHAR2(40),
    address1          VARCHAR2(255),
    address2          VARCHAR2(255),
    city              VARCHAR2(128),
    state             VARCHAR2(128),
    country           VARCHAR2(2),
    zipcode           VARCHAR2(10),
    phone             VARCHAR2(40),
    deleted           CHAR(1),
    last_update_user  VARCHAR2(40),
    last_update_date  DATE,
    customer_id       NUMBER(12)
                          DEFAULT (999) NOT NULL
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_physical_location IS 'phslc  physical location records';

CREATE SEQUENCE rhn_physical_loc_recid_seq;

