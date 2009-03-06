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
    host_probe_id   numeric   (12) not null
			constraint rhn_hstck_hstpb_probe_id_fk 
    			references rhn_host_probe( probe_id )
    			on delete cascade,
    suite_id        numeric   (12) not null
			constraint rhn_hstck_cksut_suite_id_fk 
    			references rhn_check_suites( recid )
    			on delete cascade,
			constraint rhn_hstck_suite_id_probe_id_pk primary key ( host_probe_id, suite_id )
)

;

comment on table rhn_host_check_suites 
    is 'hstck  check suites used by hosts. the host_probe_id must reference a probe oftype hostprobe.';

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
