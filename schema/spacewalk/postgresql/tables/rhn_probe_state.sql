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

--originally from the nolog instance
--probe_state current prod row count = 32615
create table rhn_probe_state
(
    probe_id                         numeric   (12) not null,
    scout_id                         numeric   (12) not null,
    state                            varchar (20),
    output                           varchar (4000),
    last_check                       date,
					constraint prbst_probe_id_scout_id_pk primary key ( probe_id, scout_id )
) 
  ;

comment on table rhn_probe_state is 'prbst  probe state';

--
--Revision 1.2  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
