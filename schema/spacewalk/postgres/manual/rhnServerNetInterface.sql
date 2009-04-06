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
rhnServerNetInterface
(
	server_id	numeric
			not null
			constraint rhn_srv_net_iface_sid_fk 
				references rhnServer(id),
	name		varchar(32)
			not null,
	ip_addr		varchar(64),
	netmask		varchar(64),
	broadcast	varchar(64),
	hw_addr		varchar(18),
	module		varchar(128),
	created		date default current_date
			not null,
	modified	date default current_date
			not null,
                        constraint rhn_srv_net_iface_sid_name_uq
                        unique( server_id, name )
)
  ;

create index rhn_srv_net_iface_sid_name_idx
        on rhnServerNetInterface ( server_id, name )
--      tablespace [[8m_tbs]]
  ;


/*
create or replace trigger
rhn_srv_net_iface_mod_trig
before insert or update on rhnServerNetInterface
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.6  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.5  2003/03/03 21:20:51  pjones
-- make module longer
--
-- Revision 1.4  2003/02/20 21:19:14  misa
-- bugzilla: 83165  Dropping non-null constraints
--
-- Revision 1.3  2003/02/11 00:01:49  misa
-- bugzilla: 83165  typo: s/modile/module/
--
-- Revision 1.2  2003/02/10 23:22:41  pjones
-- add indexes/uniqueness
-- add grants
-- add synonyms
-- changes files
-- (also the changes log for cert changes earlier)
--
-- Revision 1.1  2003/02/10 23:11:28  misa
-- bugzilla: 83165  Net interfaces table
--
