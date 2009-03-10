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
-- valid states for an email address

create table
rhnEmailAddressState
(
	id			numeric
				constraint rhn_eastate_id_pk primary key,
	label			varchar(32)
				not null
                                constraint rhn_eastate_label_uq unique,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null
)
--	tablespace [[8m_data_tbs]]
  ;

create sequence rhn_eastate_id_seq;

create index rhn_eastate_id_label_idx
	on rhnEmailAddressState ( id, label )
--	tablespace [[64k_tbs]]
  ;

create index rhn_eastate_label_id_idx
	on rhnEmailAddressState ( label, id )
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_eastate_mod_trig
before insert or update on rhnEmailAddressState
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/

--
-- Revision 1.3  2003/02/03 16:33:00  pjones
-- tablespace changes
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2003/01/10 17:44:02  pjones
-- new email address table
--
