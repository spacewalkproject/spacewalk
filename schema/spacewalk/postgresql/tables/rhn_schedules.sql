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

--schedules current prod row count = 43
create table 
rhn_schedules
(
    recid               numeric   (12) not null
        constraint rhn_sched_recid_ck check (recid > 0)
        constraint rhn_sched_recid_pk primary key
--            using index tablespace [[2m_tbs]]
            ,
    schedule_type_id    numeric   (12) not null
			constraint rhn_sched_schtp_sched_ty_fk
    			references rhn_schedule_types( recid ),
    description         varchar (40) default 'unknown' not null,
    last_update_user    varchar (40),
    last_update_date    date,
    customer_id         numeric  (12)
			constraint rhn_sched_cstmr_cust_id_fk 
    			references web_customer( id ),
			constraint rhn_cust_cust_id_desc_uq unique ( customer_id, description )
--			using tablespace [[2m_tbs]]
)
  ;

comment on table rhn_schedules 
    is 'sched  schedule definitions';

create sequence rhn_schedules_recid_seq;

--
--Revision 1.4  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.3  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.2  2004/04/30 14:46:03  kja
--Moved foreign keys for non-circular references.
--
--Revision 1.1  2004/04/16 19:51:57  kja
--More monitoring schema.
--
--
--
--
--
