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

--check_suites current prod row count = 685
create table 
rhn_check_suites
(
    recid               numeric (12) not null
        		constraint rhn_cksut_recid_pk primary key
--            		using index tablespace [[2m_tbs]]
            ,
    customer_id         numeric(12) not null,
    suite_name          varchar(40) not null,
    description         varchar(255),
    last_update_user    varchar(40) not null,
    last_update_date    date not null
) 
;

comment on table rhn_check_suites 
    is 'CKSUT  check suites';

create index rhn_cksut_cid_idx
	on rhn_check_suites( customer_id )
	tablespace [[2m_tbs]]
  ;

alter table rhn_check_suites
    add constraint rhn_cksut_cstmr_customer_id_fk
    foreign key ( customer_id )
    references web_customer( id );

--create sequence rhn_check_suites_recid_seq;

--
--Revision 1.7  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.6  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.3  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--Revision 1.2  2004/04/12 18:39:20  kja
--Added current production row count for each table as a comment to aid in
--sizing requirements.
--
--Revision 1.1  2004/04/08 22:52:31  kja
--Converting monitoring schema to rhn style -- a work in progress.
--
--
--
--
