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


CREATE TABLE rhn_url_probe_step
(
    recid              NUMBER NOT NULL 
                           CONSTRAINT rhn_urlps_recid_pk PRIMARY KEY 
                           USING INDEX TABLESPACE [[2m_tbs]], 
    url_probe_id       NUMBER NOT NULL, 
    step_number        NUMBER NOT NULL, 
    description        VARCHAR2(255), 
    url                VARCHAR2(2000) NOT NULL, 
    protocol_method    VARCHAR2(12) NOT NULL, 
    verify_links       CHAR(1) 
                           DEFAULT (0) NOT NULL 
                           CONSTRAINT rhn_urlps_ver_links_ck
                               CHECK (verify_links in ( '0' , '1' )), 
    load_subsidiary    CHAR(1) 
                           DEFAULT (0) NOT NULL 
                           CONSTRAINT rhn_urlps_load_sub_ck
                               CHECK (load_subsidiary in ( '0' , '1' )), 
    pattern            VARCHAR2(255), 
    vpattern           VARCHAR2(255), 
    post_content       VARCHAR2(4000), 
    post_content_type  VARCHAR2(255), 
    connect_warn       NUMBER 
                           DEFAULT (0) NOT NULL, 
    connect_crit       NUMBER 
                           DEFAULT (0) NOT NULL, 
    latency_warn       NUMBER 
                           DEFAULT (0) NOT NULL, 
    latency_crit       NUMBER 
                           DEFAULT (0) NOT NULL, 
    dns_warn           NUMBER 
                           DEFAULT (0) NOT NULL, 
    dns_crit           NUMBER 
                           DEFAULT (0) NOT NULL, 
    total_warn         NUMBER 
                           DEFAULT (0) NOT NULL, 
    total_crit         NUMBER 
                           DEFAULT (0) NOT NULL, 
    trans_warn         NUMBER 
                           DEFAULT (0) NOT NULL, 
    trans_crit         NUMBER 
                           DEFAULT (0) NOT NULL, 
    through_warn       NUMBER 
                           DEFAULT (0) NOT NULL, 
    through_crit       NUMBER 
                           DEFAULT (0) NOT NULL, 
    cookie_key         VARCHAR2(255), 
    cookie_value       VARCHAR2(255), 
    cookie_path        VARCHAR2(255), 
    cookie_domain      VARCHAR2(255), 
    cookie_port        NUMBER, 
    cookie_secure      CHAR(1) 
                           DEFAULT (0) NOT NULL 
                           CONSTRAINT rhn_urlps_cookie_sec_ck
                               CHECK (cookie_secure in ( '0' , '1' )), 
    cookie_maxage      NUMBER
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_url_probe_step IS 'urlps  url probe step';

CREATE UNIQUE INDEX rhn_urlps_url_pr_id_stp_n_uq
    ON rhn_url_probe_step (url_probe_id, step_number)
    TABLESPACE [[2m_tbs]];

CREATE SEQUENCE rhn_url_probe_step_recid_seq;

ALTER TABLE rhn_url_probe_step
    ADD CONSTRAINT rhn_urlps_urlpb_url_pr_id_fk FOREIGN KEY (url_probe_id)
    REFERENCES rhn_url_probe (probe_id) 
        ON DELETE CASCADE;

