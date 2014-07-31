-- oracle equivalent source sha1 c2537356ebd01ad42676801e41197e1999398c8b
--
-- Copyright (c) 2008--2012 Red Hat, Inc.
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


create or replace function rhn_confrevision_del_trig_fun() returns trigger 
as
$$
declare
        cr_removed numeric := lookup_snapshot_invalid_reason('cr_removed');
begin
        update rhnSnapshot as s
           set invalid = cr_removed
          from rhnSnapshotConfigRevision as scr
         where s.id = scr.snapshot_id
           and scr.config_revision_id = old.id;
        delete from rhnSnapshotConfigRevision
         where config_revision_id = old.id;
        return old;
end;
$$ language plpgsql;
