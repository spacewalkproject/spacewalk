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

--command_target current prod row count = 225
create table 
    rhn_command_target
(
    recid       numeric   (12) not null,
    target_type varchar2 (10) not null
        constraint cmdtg_target_type_ck check (target_type in ('cluster','node')),
    customer_id numeric   (12) not null
				constraint rhn_cmdtg_cstmr_customer_id_fk foreign key ( customer_id )
    				references web_customer( id ),
	constraint rhn_cmdtg_recid_target_type_pk primary key (recid, target_type)
)
;

comment on table rhn_command_target 
    is 'cmdtg  command target (cluster or node)';

create index rhn_cmdtg_cid_idx
	on rhn_command_target( customer_id )
--	tablespace [[4m_tbs]]
  ;

create sequence rhn_command_target_recid_seq;
