-- oracle equivalent source sha1 f7ae3f8420808ec4755224b70854497be656f08a
--
-- Copyright (c) 2013 Red Hat, Inc.
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

create or replace function
insert_crash_file(
    crash_id_in in numeric,
    filename_in in varchar,
    path_in in varchar,
    filesize_in in numeric)
returns numeric
as
$$
declare
    crash_file_id numeric;
begin
    insert into rhnServerCrashFile (id, crash_id, filename, path, filesize)
    values (sequence_nextval('rhn_server_crash_file_id_seq'), crash_id_in, filename_in, path_in, filesize_in)
    returning id into crash_file_id;
    commit;

    return crash_file_id;
exception when unique_violation then
    update rhnServerCrashFile
       set path = path_in,
           filesize = filesize_in
     where crash_id = crash_id_in and
           filename = filename_in;
    commit;

    return crash_id_in;
end;
$$ language plpgsql;
