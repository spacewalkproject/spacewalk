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
create table rhnProductName
(
    id       number
             constraint rhn_productname_id_nn not null
             constraint rhn_productname_id_pk primary key,
    label    varchar2(128)
             constraint rhn_productname_lbl_nn not null,
    name     varchar2(128)
             constraint rhn_productname_name_nn not null,
    created  date default(sysdate)
             constraint product_name_created_nn not null,
    modified date default(sysdate)
             constraint product_name_modified_nn not null
)
	storage (freelists 16)
	enable row movement
	initrans 32;

create sequence rhn_productname_id_seq start with 101;

create unique index rhn_productname_label_uq
on rhnProductName(label)
storage (freelists 16)
initrans 32;

create unique index rhn_productname_name_uq
on rhnProductName(name)
storage (freelists 16)
initrans 32;

create or replace trigger product_name_mod_trig
before insert or update on rhnProductName
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
