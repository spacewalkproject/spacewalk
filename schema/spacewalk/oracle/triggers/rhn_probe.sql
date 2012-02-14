--
-- Copyright (c) 2012 Red Hat, Inc.
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

create or replace trigger rhn_probe_insert_trigger after insert on rhn_probe
for each row
begin
    insert into time_series_purge (id, probe_id, deleted) values (:new.recid, :new.recid, 0);
end;
/

create or replace trigger rhn_probe_delete_trigger before delete on rhn_probe
for each row
begin
    update time_series_purge
       set probe_id = null
     where id = :old.recid;

    update time_series_purge
       set deleted = 1
     where id = :old.recid;
end;
/
