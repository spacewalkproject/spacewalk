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
-- $Id: $
--

create table rhnVirtSubLevel (
    id      number
            constraint rhn_vsl_id_pk primary key,
    label   varchar2(32)
            constraint rhn_vsl_label_nn not null,
    name    varchar2(128)
            constraint rhn_vsl_name_nn not null,
    created date default sysdate
            constraint rhn_vsl_created_nn not null,
    modified date default sysdate
             constraint rhn_vsl_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create sequence rhn_virt_sl_seq;    

create index rhn_vsl_label_id_name_idx
    on rhnVirtSubLevel(label, id, name)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32;


