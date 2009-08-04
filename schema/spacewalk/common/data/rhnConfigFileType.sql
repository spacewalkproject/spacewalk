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

insert into rhnConfigFileType values (1, 'file', 'File', sysdate, sysdate);
insert into rhnConfigFileType values (2, 'directory', 'Directory', sysdate, sysdate);
insert into rhnConfigFileType values (3, 'symlink', 'Symlink', sysdate, sysdate);

--
--
-- Revision 1.2  2005/02/10 21:56:02  jslagle
-- Added documentation changes
--
--

