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
--/

create table
rhnTagName
(
        id              numeric not null
    	    	    	constraint rhn_tn_id_pk primary key,
        name            varchar(128) not null
			constraint rhn_tn_name_uq unique,
       	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
	;

create sequence rhn_tagname_id_seq;
/*
create or replace trigger
rhn_tn_mod_trig
before insert or update on rhnTagName
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/

--
-- Revision 1.2  2003/10/16 18:50:13  bretm
-- bugzilla:  107189
--
-- o  functions for tagging (single + bulk)
-- o  make tag names 128 instead of 256 maxlength
--
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
