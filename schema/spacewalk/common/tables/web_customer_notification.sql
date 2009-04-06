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


CREATE TABLE web_customer_notification
(
    id                     NUMBER NOT NULL 
                               CONSTRAINT web_cust_not_id_pk PRIMARY KEY 
                               USING INDEX TABLESPACE [[64k_tbs]], 
    org_id                 NUMBER NOT NULL 
                               CONSTRAINT web_cust_not_oid_fk
                                   REFERENCES web_customer (id) 
                                   ON DELETE CASCADE, 
    contact_email_address  VARCHAR2(150) NOT NULL, 
    creation_date          DATE NOT NULL
)
ENABLE ROW MOVEMENT
;

CREATE SEQUENCE web_cust_notif_seq START WITH 1000000;

