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
-- channel families that are part of a satellite cert
--

create table
rhnSatelliteChannelFamily
(
        server_id           numeric
                            not null
                            constraint rhn_sat_cf_sid_fk
                            references rhnServer(id),
        channel_family_id   numeric
                            not null
                            constraint rhn_sat_cf_cfid_fk
                            references rhnChannelFamily(id)
                            on delete cascade,
        quantity            numeric,
        created             date default (current_date)
                            not null,
        modified            date default (current_date)
                            not null,
                            constraint rhn_sat_cf_sid_cfid_uq
                            unique ( server_id, channel_family_id )
)
  ;

/*
create or replace trigger
rhn_sat_cf_mod_trig
before insert or update on rhnSatelliteChannelFamily
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
*/

create index rhn_sat_cf_sid_cfid_idx on
	rhnSatelliteChannelFamily ( server_id, channel_family_id )
--	tablespace [[2m_tbs]]
        ;
create index rhn_sat_cf_cfid_sid_idx on
        rhnSatelliteChannelFamily( channel_family_id, server_id )
--	tablespace [[2m_tbs]]
        ;

--
-- Revision 1.4  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.3  2003/02/10 17:01:41  pjones
-- missed this file in the last commit
--
-- Revision 1.2  2003/02/10 15:41:25  misa
-- bugzilla: 83950  Satellite cert schema
--
-- Revision 1.1  2003/02/04 21:24:53  misa
-- bugzilla: 82844  Added schema support; didn't run it in dev yet, to avoid breaking the web code
--
