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
-- this creates the user_group_id_t type

create or replace type user_group_id_t as table of NUMBER
/

--
-- Revision 1.2  2002/05/09 22:34:53  pjones
-- argh, ; doesn't work right here
--
-- Revision 1.1  2002/05/09 22:31:42  pjones
-- make types first-class schema
--
