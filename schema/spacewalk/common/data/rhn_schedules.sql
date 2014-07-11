--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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
-- 
--

--data for rhn_schedules (uses sequence)
--only include the 24 x 7 schedule

insert into rhn_schedules(recid,schedule_type_id,description,last_update_user,
last_update_date,customer_id) 
    values ( sequence_nextval('rhn_schedules_recid_seq'),1,'24x7','system',current_timestamp,NULL);
commit;

