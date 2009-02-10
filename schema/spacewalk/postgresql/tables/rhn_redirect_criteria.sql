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

--redirect_criteria current prod row count = 27332
create table 
rhn_redirect_criteria
(
    recid           numeric   (12) not null
        constraint rhn_rdrcr_recid_pk primary key
--            using index tablespace [[4m_tbs]]
            ,
    redirect_id     numeric   (12) not null
			constraint rhn_rdrcr_rdrct_redirect_id_fk
    			references rhn_redirects( recid ),
    on delete cascade
    match_param     varchar (255) not null
			constraint rhn_rdrcr_rdrmt_match_nm_fk
        		references rhn_redirect_match_types( name ),
    match_value     varchar (255),
    inverted        char     (1) default 0 not null
)
  ;

comment on table rhn_redirect_criteria 
    is 'rdrcr  redirect criteria';

create index rhn_rdrcr_redirect_id_idx 
    on rhn_redirect_criteria ( redirect_id )
--    tablespace [[4m_tbs]]
  ;

create sequence rhn_redirect_crit_recid_seq;

--
--Revision 1.4  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.3  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.2  2004/04/19 17:21:23  kja
--Tweaks from auditing not null constraints, storage on tables, and non-unique
--indexes.
--
--Revision 1.1  2004/04/16 02:21:57  kja
--More monitoring schema.
--
--
--
--
--
