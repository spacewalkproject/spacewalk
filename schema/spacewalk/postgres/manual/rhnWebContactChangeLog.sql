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

create table rhnWebContactChangeLog (
    id                     numeric 
                           constraint rhn_wcon_cl_id_pk primary key,
    web_contact_id         numeric not null
                           constraint rhn_wcon_cl_wcon_id_fk references web_contact(id)
                           on delete cascade,
    web_contact_from_id    numeric
                           constraint rhn_wcon_cl_wcon_from_id_fk references web_contact(id)
                           on delete set null,
    change_state_id        numeric not null
                           constraint rhn_wcon_cl_csid_fk references rhnWebContactChangeState(id),
    date_completed         timestamp default (current_timestamp) not null
)
  ;

create sequence rhn_wcon_disabled_seq;

create index rhn_wcon_disabled_wcon_id_idx
       on rhnWebContactChangeLog(web_contact_id)
;

--
--
--
