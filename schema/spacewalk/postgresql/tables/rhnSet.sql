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
rhnSet
(
	user_id		numeric not null
			constraint rhn_set_user_fk
				   references web_contact(id)
				   on delete cascade,
	label		varchar(32) not null,
	element		numberic not null,
	element_two	numeric,
	element_three	numeric,
	constraint	rhn_set_user_label_elem_unq
		UNIQUE(user_id, label, element, element_two, element_three)
--		using index tablespace [[8m_tbs]]
)
;



--
-- Revision 1.9  2003/02/18 16:08:49  pjones
-- cascades for delete_user
--
-- Revision 1.8  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.7  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
