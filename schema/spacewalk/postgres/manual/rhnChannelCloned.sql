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
create table
rhnChannelCloned
(
	original_id		numeric
				not null
				constraint rhn_channelclone_fcid_fk
					references rhnChannel(id)
					on delete cascade,
	id		        numeric
				constraint rhn_channelclone_id_pk primary key
				constraint rhn_channelclone_tcid_fk
					references rhnChannel(id)
					on delete cascade,
	created			date default(current_date)
				not null,
	modified		date default(current_date)
				not null,
                                constraint rhn_channelclone_fcid_tcid_uq 
                                unique( original_id, id )
)
	
  ;

create index rhn_channelclone_fcid_tcid_idx
	on rhnChannelCloned ( original_id, id )
--	tablespace [[2m_tbs]]
  ;

create index rhn_channelclone_tcid_fcid_idx
	on rhnChannelCloned ( id, original_id )
--	tablespace [[2m_tbs]]
  ;
/*
create or replace trigger
rhn_channelclone_mod_trig
before insert or update on rhnChannelCloned
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/
