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

-- status for an rhnUserMessage
create table
rhnUserMessageStatus
(
	id		numeric
			not null
			constraint rhn_um_status_id_pk primary key
--			using index tablespace [[64k_tbs]]
                        ,
	label		varchar(48)
			not null
                        constraint rhn_um_status_label_uq
                        unique
--                      tablespace [[64k_tbs]]
)
  ;

create sequence rhn_um_status_id_seq;

-- last created gets used in Rule, make it the most useful index.
create index rhn_um_status_label_id_idx
	on rhnUserMessageStatus(label,id)
--	tablespace [[64k_tbs]]
  ;

--
-- Revision 1.2  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.1  2002/07/25 19:56:34  pjones
-- message schema, take 2.
--
