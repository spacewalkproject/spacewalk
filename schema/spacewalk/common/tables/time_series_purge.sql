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
--


create table time_series_purge
(
    id        number not null
                  constraint time_series_purge_pk primary key,
    probe_id  number
                  constraint time_series_purge_pid_fk
                  references rhn_probe(recid),
    deleted   number,
    created   date default (sysdate) not null,
    modified  date default (sysdate) not null
)
enable row movement;

alter table time_series_purge
        add constraint time_series_purge
      check (id = probe_id);

create index time_series_purge_id_del_idx
    on time_series_purge(id, deleted);
