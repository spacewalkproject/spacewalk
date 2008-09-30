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

--check_suite_probe current prod row count = 4923
create table 
rhn_check_suite_probe
(
    probe_id        number   (12)
        constraint rhn_ckspb_probe_id_nn not null
        constraint rhn_ckspb_probe_id_pk primary key
            using index tablespace [[4m_tbs]]
            storage( pctincrease 1 freelists 16 ),
    probe_type      varchar2 (12) default 'suite' 
        constraint rhn_ckspb_probe_type_nn not null
        constraint rhn_ckspb_probe_type_ck check ( probe_type = 'suite' ),
    check_suite_id  number   (12)
        constraint rhn_ckspb_check_suite_id_nn not null
) 
    storage ( pctincrease 1 freelists 16 ) 
    enable row movement
    initrans 32; 

comment on table rhn_check_suite_probe 
    is 'CKSPB  Check suite probe definitions (monitoring)';

create index rhn_ckspb_check_suite_id_idx 
    on rhn_check_suite_probe ( check_suite_id )
    tablespace [[4m_tbs]]
    storage( pctincrease 1 freelists 16 )
    initrans 32;

alter table rhn_check_suite_probe
    add constraint rhn_ckspb_cksut_ck_suite_id_fk
    foreign key ( check_suite_id )
    references rhn_check_suites( recid )
    on delete cascade;

--$Log$
--Revision 1.5  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.4  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
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
