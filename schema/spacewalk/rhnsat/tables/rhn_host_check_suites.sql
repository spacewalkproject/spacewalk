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

--host_check_suites current prod row count = 4137
create table 
rhn_host_check_suites
(
    host_probe_id   number   (12)
        constraint rhn_hstck_host_probe_nn not null,
    suite_id        number   (12)
        constraint rhn_hstck_suite_id_nn not null
)
    enable row movement
  ;

comment on table rhn_host_check_suites 
    is 'hstck  check suites used by hosts. the host_probe_id must reference a probe oftype hostprobe.';

create unique index rhn_hstck_suite_id_probe_id_pk 
    on rhn_host_check_suites ( host_probe_id , suite_id )
    tablespace [[2m_tbs]]
  ;

alter table rhn_host_check_suites 
    add constraint rhn_hstck_suite_id_probe_id_pk 
    primary key ( host_probe_id, suite_id );

alter table rhn_host_check_suites
    add constraint rhn_hstck_cksut_suite_id_fk
    foreign key ( suite_id )
    references rhn_check_suites( recid )
    on delete cascade;

alter table rhn_host_check_suites
    add constraint rhn_hstck_hstpb_probe_id_fk
    foreign key ( host_probe_id )
    references rhn_host_probe( probe_id )
    on delete cascade;

--
--Revision 1.3  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
--
--
--
--
--
