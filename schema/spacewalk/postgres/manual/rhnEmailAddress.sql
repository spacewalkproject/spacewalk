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
-- This holds information about email addresses

create table
rhnEmailAddress
(
	id			numeric
				constraint rhn_eaddress_id_pk primary key
--                              using index tablespace [[8m_tbs]]
                                ,
	address			varchar(128)
				not null,
	user_id			numeric
				not null
				constraint rhn_eaddress_uid_fk
				references web_contact(id)
				on delete cascade,
        state_id		numeric not null
				constraint rhn_eaddress_sid_fk
				references rhnEmailAddressState(id),
	next_action		date,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_eaddress_uid_sid_uq 
                                unique ( user_id, state_id )
)
--	tablespace [[8m_data_tbs]]
  ;

create sequence rhn_eaddress_id_seq;


-- this gets a much higher hitrate with erratamail
create index rhn_eaddress_uid_sid_addr_idx
        on rhnEmailAddress ( user_id, state_id, address )
--      tablespace [[8m_tbs]]
  ;
 -- ugh.  Name too long the sane way, shortened to fit.

create index rhn_eaddress_niusa_idx
        on rhnEmailAddress ( next_action, id, user_id, state_id, address )
--        tablespace [[8m_tbs]]
  ;

/*
create or replace trigger
rhn_eaddress_mod_trig
before insert or update on rhnEmailAddress
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.10  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.9  2003/02/03 16:33:00  pjones
-- tablespace changes
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2003/01/22 18:48:37  cturner
-- rename column, add intermediary email step
--
-- Revision 1.6  2003/01/21 16:15:06  pjones
-- s/attempts,last_attempt/next_attempt/
--
-- Revision 1.5  2003/01/16 17:29:23  pjones
-- last_attempt date column, so we know when we tried
--
-- Revision 1.4  2003/01/15 18:17:55  pjones
-- add attempts field
--
-- Revision 1.3  2003/01/10 20:00:18  pjones
-- move indexes and uq/pk out of rhnEmailAddress
-- revamp population script
--
-- Revision 1.2  2003/01/10 18:03:53  pjones
-- change the address column name
--
-- Revision 1.1  2003/01/10 17:44:02  pjones
-- new email address table
--
