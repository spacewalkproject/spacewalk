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
--
--
--

--url_probe_step current prod row count = 399
create table 
rhn_url_probe_step
(
    recid               numeric(12)
                        not null
                        constraint rhn_urlps_recid_pk primary key
--                      using index tablespace [[2m_tbs]]
            ,
    url_probe_id        numeric(12)
                        not null
                        constraint rhn_urlps_urlpb_url_pr_id_fk references rhn_url_probe(probe_id)
                        on delete cascade,
    step_number         numeric   (3)
                        not null,
    description         varchar(255),
    url                 varchar(2000)
                        not null,
    protocol_method     varchar(12)
                        not null,
    verify_links        char(1) default 0
                        not null
                        constraint rhn_urlps_ver_links_ck check (verify_links in ('0','1')),
    load_subsidiary     char(1) default 0
                        not null
        constraint rhn_urlps_load_sub_ck check (load_subsidiary in ('0','1')),
    pattern             varchar(255),
    vpattern            varchar(255),
    post_content        varchar(4000),
    post_content_type   varchar(255),
    connect_warn        numeric(10,3)  default 0
                        not null,
    connect_crit        numeric(10,3)  default 0
                        not null,
    latency_warn        numeric(10,3)  default 0
                        not null,
    latency_crit        numeric(10,3)  default 0
                        not null,
    dns_warn            numeric(10,3)  default 0
                        not null,
    dns_crit            numeric(10,3)  default 0
                        not null,
    total_warn          numeric(10,3)  default 0
                        not null,
    total_crit          numeric(10,3)  default 0
                        not null,
    trans_warn          numeric(12)    default 0
                        not null,
    trans_crit          numeric(12)    default 0
                        not null,
    through_warn        numeric(12)    default 0
                        not null,
    through_crit        numeric(12)    default 0
                        not null,
    cookie_key          varchar(255),
    cookie_value        varchar(255),
    cookie_path         varchar(255),
    cookie_domain       varchar(255),
    cookie_port         numeric(5),
    cookie_secure       char(1)     default 0
                        not null
        constraint rhn_urlps_cookie_sec_ck check (cookie_secure in ('0','1')),
    cookie_maxage       numeric(9),
                        constraint rhn_urlps_url_pr_id_stp_n_uq
                        unique( url_probe_id, step_number )
--                        using tiablespace [[2m_tbs]]
)
  ;

comment on table rhn_url_probe_step 
    is 'urlps  url probe step';

create sequence rhn_url_probe_step_recid_seq;

--
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
--
--
--
