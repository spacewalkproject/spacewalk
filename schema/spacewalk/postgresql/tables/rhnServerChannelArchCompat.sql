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
rhnServerChannelArchCompat
(
        server_arch_id	numeric
                        not null
                        constraint rhn_sc_ac_said_fk 
			references rhnServerArch(id),
	channel_arch_id	numeric
			not null
			constraint rhn_sc_ac_caid_fk
			references rhnChannelArch(id),
	created		date default(current_date)
			not null,
	modified	date default(current_date)
			not null
)
  ;

create index rhn_sc_ac_caid_paid
	on rhnServerChannelArchCompat(server_arch_id, channel_arch_id)
--	tablespace [[64k_tbs]]
  ;

create index rhn_sc_ac_paid_caid
	on rhnServerChannelArchCompat(channel_arch_id, server_arch_id)
--	tablespace [[64k_tbs]]
  ;

/*
create or replace trigger
rhn_sc_ac_mod_trig
before insert or update on rhnServerChannelArchCompat
for each row
begin
        :new.modified := sysdate;
end;
/
show errors
*/
--
-- Revision 1.6  2004/02/19 20:56:44  misa
-- Forgot to remove a line
--
-- Revision 1.5  2004/02/19 17:39:45  misa
-- Geeting rid of the server_arch_id uniqueness constraint, seems to be useless
--
-- Revision 1.4  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.3  2002/11/14 16:25:50  misa
-- Fixing the uniqueness constraint
--
-- Revision 1.2  2002/11/14 00:36:02  misa
-- No need for preference here; added another uniqueness constraint
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
