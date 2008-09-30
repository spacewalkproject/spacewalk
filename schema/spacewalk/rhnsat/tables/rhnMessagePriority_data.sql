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
-- data for rhnMessagePriority

insert into rhnMessagePriority values (
	rhn_m_priority_id_seq.nextval, 'warning'
);

insert into rhnMessagePriority values (
	rhn_m_priority_id_seq.nextval, 'error'
);



--
-- Revision 1.3  2002/08/12 16:35:50  bretm
-- o  heh, need this one too.
--
-- Revision 1.2  2002/08/12 16:31:40  bretm
-- o  for now, dagg is looking for warnings or errors...
--
-- Revision 1.1  2002/07/29 20:26:23  pjones
-- add support for labeled message priorities
--
