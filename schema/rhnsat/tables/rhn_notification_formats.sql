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

--reference table
--notification_formats current prod row count = 4
create table 
rhn_notification_formats
(
    recid               number   (12)
        constraint rhn_ntfmt_recid_nn not null
        constraint rhn_ntfmt_recid_pk primary key
            using index tablespace [[64k_tbs]]
            storage( pctincrease 1 freelists 16 )
            initrans 32,
    customer_id         number   (12),
    description         varchar2 (255)
        constraint rhn_ntfmt_desc_nn not null,
    subject_format      varchar2 (4000),
    body_format         varchar2 (4000)
        constraint rhn_ntfmt_body_fmt_nn not null,
    max_subject_length  number   (12),
    max_body_length     number   (12) default 1920
        constraint rhn_ntfmt_max_body_nn not null,
    reply_format        varchar2 (4000)
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

comment on table rhn_notification_formats 
    is 'ntfmt  notification message formats';

create index rhn_ntfmt_customer_idx 
    on rhn_notification_formats ( customer_id )
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;

alter table rhn_notification_formats
    add constraint rhn_ntfmt_customer_fk
    foreign key ( customer_id )
    references web_customer( id );

create sequence rhn_ntfmt_recid_seq;

--$Log$
--Revision 1.6  2004/05/12 01:21:45  kja
--Added synonyms for the sequences.  Corrected some sequence names to start with
--rhn_.
--
--Revision 1.5  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.4  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.3  2004/04/16 22:10:00  kja
--Added missing sequences.
--
--Revision 1.2  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.1  2004/04/13 19:36:13  kja
--More monitoring schema.
