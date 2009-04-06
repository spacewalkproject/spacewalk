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

--contact_groups current prod row count = 399
create table 
rhn_contact_groups
(  
    recid                   numeric(12) not null
        			constraint rhn_cntgp_recid_notzero check (recid > 0)
        			constraint rhn_cntgp_recid_pk primary key
--		            	using index tablespace [[2m_tbs]]
            ,
    contact_group_name      varchar(30) not null,
    customer_id             numeric(12) not null
				constraint rhn_cntgp_cstmr_customer_id_fk 
    				references web_customer( id ),
    strategy_id             numeric(12) not null
				constraint rhn_cntgp_strat_strategy_id_fk 
    				references rhn_strategies( recid ),
    ack_wait                numeric(4) not null
        			constraint rhn_cntgp_ack_wait_ck check ( ack_wait < 20160 ),
    rotate_first            char(1) not null
        			constraint rhn_cntgp_rotate_f_ck check (rotate_first in (0,1)),
    last_update_user        varchar(40) not null,
    last_update_date        date not null,
    notification_format_id  numeric(12) default 4 not null
				constraint rhn_ntfmt_cntgp_id_fk 
    				references rhn_notification_formats( recid )
)
  ;

comment on table rhn_contact_groups 
    is 'cntgp  contact group definitions';

create index rhn_cntgp_strategy_id_idx
    on rhn_contact_groups ( strategy_id )
--    tablespace [[2m_tbs]]
  ;

create index rhn_cntgp_customer_id_idx
    on rhn_contact_groups ( customer_id )
--    tablespace [[2m_tbs]]
  ;

create sequence rhn_contact_groups_recid_seq;

--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.2  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--
--
--
