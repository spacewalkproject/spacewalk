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
-- data for rhnTransactionOperation

insert into rhnTransactionOperation (id, label) values (1,'insert');
insert into rhnTransactionOperation (id, label) values (2,'delete');
insert into rhnTransactionOperation (id, label) values (3,'upgrade');

--
-- Revision 1.2  2003/07/02 21:33:28  pjones
-- bugzilla: none
--
-- add "upgrade" transaction type
--
-- Revision 1.1  2002/09/25 19:21:36  pjones
-- more of the transaction changes
--
