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

--url_probe current prod row count = 182
create table 
rhn_url_probe
(
    username                         varchar2 (40),
    password                         varchar2 (255),
    cookie_enabled                   char     (1)   default 0
        constraint rhn_urlpb_cookie_en_nn not null,
    multi_step                       char     (1)   default 0
        constraint rhn_urlpb_multi_step_nn not null
        constraint rhn_urlpb_multi_step_ck check (multi_step in ('0','1')),
    run_on_scouts                    char     (1)   default ('1')
        constraint rhn_urlpb_run_on_scouts_nn not null
        constraint rhn_urlpb_run_on_scouts_ck 
            check (run_on_scouts in ('0','1')),
    probe_id                         number   (12)
        constraint rhn_urlpb_probe_id_nn not null
        constraint rhn_urlpb_probe_id_pk primary key
            using index tablespace [[2m_tbs]]
            ,
    probe_type                       varchar2 (12)  default 'url'
        constraint rhn_urlpb_probe_type_nn not null
        constraint rhn_urlpb_probe_type_ck check (probe_type='url'),
    sat_cluster_id                   number   (12),
    scout_warning_threshold_is_all   char     (1)   default '1'
        constraint rhn_urlpb_scout_warn_isall_nn not null,
    scout_crit_threshold_is_all      char     (1)   default '1'
        constraint rhn_urlpb_scout_crit_isall_nn not null,
    scout_warning_threshold          number   (12)  default -1,
    scout_critical_threshold         number   (12)  default -1
)
    enable row movement
  ;

comment on table rhn_url_probe 
    is 'urlpb  url probe';

alter table rhn_url_probe
    add constraint rhn_urlpb_probe_pr_id_pr_fk
    foreign key ( probe_id, probe_type )
    references rhn_probe( recid, probe_type )
    on delete cascade;

create index rhn_url_probe_pid_ptype_idx
    on rhn_url_probe ( probe_id, probe_type )
  ;

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
