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
rhnMessageType
(
	id		number
			constraint rhn_m_type_id_nn not null
			constraint rhn_m_type_id_pk primary key
				using index tablespace [[64k_tbs]],
	label		varchar2(48)
			constraint rhn_m_type_label_nn not null,
	name		varchar2(96)
			constraint rhn_m_type_name_nn not null
)
	enable row movement
  ;

create sequence rhn_mt_id_seq;

create unique index rhn_m_type_label_uq
	on rhnMessageType(label)
	tablespace [[64k_tbs]]
  ;
create unique index rhn_m_type_name_uq
	on rhnMessageType(name)
	tablespace [[64k_tbs]]
  ;

create index rhn_m_type_label_id_idx
	on rhnMessageType(label,id)
	tablespace [[64k_tbs]]
  ;

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
