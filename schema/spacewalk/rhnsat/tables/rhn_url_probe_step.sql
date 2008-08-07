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
--
--$Id$
--
--

--url_probe_step current prod row count = 399
create table 
rhn_url_probe_step
(
    recid               number   (12)
        constraint rhn_urlps_recid_nn not null
        constraint rhn_urlps_recid_pk primary key
            using index tablespace [[2m_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    url_probe_id        number   (12)
        constraint rhn_urlps_url_prob_id_nn not null,
    step_number         number   (3)
        constraint rhn_urlps_url_step_no_nn not null,
    description         varchar2 (255),
    url                 varchar2 (2000)
        constraint rhn_urlps_url_nn not null,
    protocol_method     varchar2 (12)
        constraint rhn_urlps_protocol_nn not null,
    verify_links        char     (1)     default 0
        constraint rhn_urlps_ver_links_nn not null
        constraint rhn_urlps_ver_links_ck check (verify_links in ('0','1')),
    load_subsidiary     char     (1)     default 0
        constraint rhn_urlps_load_sub_nn not null
        constraint rhn_urlps_load_sub_ck check (load_subsidiary in ('0','1')),
    pattern             varchar2 (255),
    vpattern            varchar2 (255),
    post_content        varchar2 (4000),
    post_content_type   varchar2 (255),
    connect_warn        number   (10,3)  default 0
        constraint rhn_urlps_conn_warn_nn not null,
    connect_crit        number   (10,3)  default 0
        constraint rhn_urlps_conn_crit_nn not null,
    latency_warn        number   (10,3)  default 0
        constraint rhn_urlps_late_warn_nn not null,
    latency_crit        number   (10,3)  default 0
        constraint rhn_urlps_late_crit_nn not null,
    dns_warn            number   (10,3)  default 0
        constraint rhn_urlps_dns_warn_nn not null,
    dns_crit            number   (10,3)  default 0
        constraint rhn_urlps_dns_crit_nn not null,
    total_warn          number   (10,3)  default 0
        constraint rhn_urlps_total_warn_nn not null,
    total_crit          number   (10,3)  default 0
        constraint rhn_urlps_total_crit_nn not null,
    trans_warn          number   (12)    default 0
        constraint rhn_urlps_trans_warn_nn not null,
    trans_crit          number   (12)    default 0
        constraint rhn_urlps_trans_crit_nn not null,
    through_warn        number   (12)    default 0
        constraint rhn_urlps_thru_warn_nn not null,
    through_crit        number   (12)    default 0
        constraint rhn_urlps_thru_crit_nn not null,
    cookie_key          varchar2 (255),
    cookie_value        varchar2 (255),
    cookie_path         varchar2 (255),
    cookie_domain       varchar2 (255),
    cookie_port         number   (5),
    cookie_secure       char     (1)     default 0
        constraint rhn_urlps_cookie_sec_nn not null
        constraint rhn_urlps_cookie_sec_ck check (cookie_secure in ('0','1')),
    cookie_maxage       number   (9)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_url_probe_step 
    is 'urlps  url probe step';

create unique index rhn_urlps_url_pr_id_stp_n_uq 
    on rhn_url_probe_step ( url_probe_id, step_number )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_url_probe_step
    add constraint rhn_urlps_urlpb_url_pr_id_fk
    foreign key ( url_probe_id )
    references rhn_url_probe( probe_id )
    on delete cascade;

create sequence rhn_url_probe_step_recid_seq;

--$Log$
--Revision 1.3  2004/05/07 23:30:22  kja
--Shortened constraint/other names as needed.  Fixed minor syntax errors.
--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 21:17:21  kja
--More monitoring tables.
--
--
--$Id$
--
--
