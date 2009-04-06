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
-- data for rhnActionStatus

insert into rhnActionStatus values (0, 'Queued', current_timestamp, current_timestamp);
insert into rhnActionStatus values (1, 'Picked Up', current_timestamp, current_timestamp);
insert into rhnActionStatus values (2, 'Completed', current_timestamp, current_timestamp);
insert into rhnActionStatus values (3, 'Failed', current_timestamp, current_timestamp);

