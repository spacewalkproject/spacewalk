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
-- information about a server which is an rhn satellite server
--

create table
rhnSatelliteInfo
(
        server_id           numeric
                            not null
                            constraint rhn_satellite_info_sid_uq unique
                            constraint rhn_satellite_info_sid_fk
                            references rhnServer(id),
	evr_id		    numeric
			    constraint rhn_satellite_info_eid_fk
			    references rhnPackageEVR(id),
        cert                bytea
                            not null,
        product             varchar(256)
                            not null,
        owner               varchar(256)
                            not null,
        issued_string       varchar(256),
        expiration_string   varchar(256),
        created             date default (current_date)
                            not null,
        modified            date default (current_date)
                            not null
)
  ;

/*
create or replace trigger
rhn_satellite_info_mod_trig
before insert or update on rhnSatelliteInfo
for each row
begin
    :new.modified := sysdate;
end;
/
show errors
*/

create index rhn_satellite_info_sid_idx on
	rhnSatelliteInfo ( server_id )
--	tablespace [[2m_tbs]]
        ;

--
-- Revision 1.9  2004/07/08 18:55:01  pjones
-- bugzilla: 127472 -- use evr_id , not a generic number
--
-- Revision 1.8  2004/07/06 19:05:06  pjones
-- bugzilla: 126577 -- add version to rhnSatelliteInfo
--
-- Revision 1.7  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.6  2003/10/21 19:35:19  pjones
-- bugzilla: 107200 -- rhnSatelliteServerGroup now, so we can handle
-- arbitrary server group entitlements for satellite
--
-- Revision 1.5  2003/02/10 16:51:36  pjones
-- add grants/synonyms for rhnSatelliteChannelFamily
-- change how the indexes are built
-- minor reformatting
--
-- Revision 1.4  2003/02/10 15:41:25  misa
-- bugzilla: 83950  Satellite cert schema
--
-- Revision 1.3  2003/02/04 21:24:53  misa
-- bugzilla: 82844  Added schema support; didn't run it in dev yet, to avoid breaking the web code
--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/03/25 23:45:37  pjones
-- satellite info, so far just cert
--
