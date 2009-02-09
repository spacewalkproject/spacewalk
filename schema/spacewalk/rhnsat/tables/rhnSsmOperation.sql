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

create table
rhnSsmOperation
(
    id          number
                constraint rhn_ssmop_id_nn not null
                constraint rhn_ssmop_id_pk primary key
                    using index tablespace [[4m_tbs]],
    user_id     number
                constraint rhn_ssmop_user_nn not null
                constraint rhn_ssmop_user_fk
                    references rhnUser(id)
                    on delete cascade,
    description varchar2(256)
                constraint rhn_ssmop_desc_nn not null,
    status      varchar2(32)
                constraint rhn_ssmop_st_nn not null,
    started     date
                constraint rhn_ssmop_strt_nn not null,
    modified    date default (sysdate)
                constraint rhn_ssmop_mod_nn not null
)
;


create sequence rhn_ss_op_seq;

create or replace trigger
rhn_ssmop_mod_trig
before insert or update on rhnSsmOperation
for each row
begin
    :new.modified := sysdate;
end;
/
show errors

