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


-- data for rhnProductLine

insert into rhnProductLine
(id, label, name)
values
(1, 'rhl', 'Red Hat Linux');

insert into rhnProductLine
(id, label, name)
values
(2, 'rhel', 'Red Hat Enterprise Linux');

insert into rhnProductLine
(id, label, name)
values
(3, 'rhdb', 'Red Hat Database');

insert into rhnProductLine
(id, label, name)
values
(4, 'stronghold', 'Stronghold');

--commit;
