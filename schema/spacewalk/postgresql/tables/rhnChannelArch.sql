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
rhnChannelArch
(
	id		numeric not null
			primary key,
	label		varchar(64) not null
			constraint rhn_carch_label_uq unique,
	arch_type_id	numeric not null
			constraint rhn_carch_atid_fk
				references rhnArchType(id),
	name		varchar(64) not null,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null,
			constraint rhn_carch_id_l_n_idx unique (id, label, name)
--			using index tablespace [[2m_tbs]]
)
;

--create sequence rhn_channel_arch_id_seq start with 500;

-- these must be in this order.

-- these too.
create index rhn_carch_l_id_n_idx
	on rhnChannelArch(label,id,name)
--	tablespace [[2m_tbs]]
  ;

--create or replace trigger
--rhn_carch_mod_trig
--before insert or update on rhnChannelArch
--for each row
--begin
--        :new.modified := sysdate;
--end;
--/
--show errors

--
-- Revision 1.5  2004/02/05 18:45:58  pjones
-- bugzilla: 115009 -- make the labels really big
--
-- Revision 1.4  2004/02/05 17:33:12  pjones
-- bugzilla: 115009 -- rhnArchType is new, and has changes to go with it
--
-- Revision 1.3  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.2  2002/11/13 22:59:59  misa
-- Added a sequence; added data
--
-- Revision 1.1  2002/11/13 21:50:21  pjones
-- new arch system
--
