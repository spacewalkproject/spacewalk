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

--originally from the nolog instance
--current_state_summaries current prod row count = 363
create table 
rhn_current_state_summaries
(
    customer_id                      number   (12)
        constraint rhn_cursu_cust_id_nn not null,
    template_id                      varchar2 (10)
        constraint rhn_cursu_template_id_nn not null,
    state                            varchar2 (20)
        constraint rhn_cursu_state_nn not null,
    state_count                      number   (9),
    last_check                       date
)  
    storage ( freelists 16 )
    initrans 32;

comment on table rhn_current_state_summaries
    is 'cursu  current state summaries (monitoring)';

create unique index rhn_current_state_summaries_pk 
on rhn_current_state_summaries ( customer_id, template_id, state )
    tablespace [[2m_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_current_state_summaries 
    add constraint rhn_current_state_summaries_pk 
    primary key ( customer_id, template_id, state );

--$Log$
--Revision 1.2  2004/05/10 20:57:44  kja
--Correcting case of data for rhn_synch_probe_state.  Fixed comment for
--rhn_current_state_summaries.
--
--Revision 1.1  2004/04/21 19:19:11  kja
--Added nolog tables.
--
