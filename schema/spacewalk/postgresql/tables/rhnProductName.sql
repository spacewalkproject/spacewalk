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
    id       numeric not null
             constraint rhn_productname_id_pk primary key,
    label    varchar(128) not null
	     constraint rhn_productname_label_uq unique,
    name     varchar(128) not null
	     constraint rhn_productname_name_uq unique,
    created  timestamp default (current_timestamp) not null,
    modified timestamp default (current_timestamp) not null
)
;

create sequence rhn_productname_id_seq start with 101;

--create or replace trigger product_name_mod_trig
--before insert or update on rhnProductName
--for each row
--begin
--    :new.modified := sysdate;
--end;
--/
--show errors
