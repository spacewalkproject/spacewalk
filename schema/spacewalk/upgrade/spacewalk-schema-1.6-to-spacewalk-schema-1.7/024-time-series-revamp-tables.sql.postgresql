-- oracle equivalent source sha1 9f5d34103bc375136b8621bf189ce9b7f1d0189c
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
    id        numeric not null
                  constraint time_series_purge_pk primary key,
    probe_id  numeric
                  constraint time_series_purge_pid_fk
                  references rhn_probe(recid),
    deleted   numeric,
    created   timestamptz default (current_timestamp) not null,
    modified  timestamptz default (current_timestamp) not null
);

alter table time_series_purge
        add constraint time_series_purge
      check (id = probe_id);

create index time_series_purge_id_del_idx
    on time_series_purge(id, deleted);

-- populate time_series_purge with values from rhn_probe
insert into time_series_purge (id, probe_id, deleted) (select rp.recid, rp.recid, 0 from rhn_probe rp);
commit;

create table time_series_data
(
    org_id      numeric not null,
    probe_id    numeric not null
                    constraint time_series_data_pid_fk references
                    time_series_purge(id),
    probe_desc  varchar(64),
    entry_time  numeric not null,
    data        varchar(1024)
);

create index time_series_data_pid_time_idx on time_series_data(probe_id, entry_time);

-- triggers
create or replace function rhn_probe_insert_trigger_fun() returns trigger as
$$
begin
    insert into time_series_purge (id, probe_id, deleted) values (new.recid, new.recid, 0);
    return new;
end;
$$ language plpgsql;

create trigger rhn_probe_insert_trigger after insert on rhn_probe
for each row
execute procedure rhn_probe_insert_trigger_fun();

create or replace function rhn_probe_delete_trigger_fun() returns trigger as
$$
begin
    update time_series_purge
       set probe_id = null
     where id = old.recid;

    update time_series_purge
       set deleted = 1
     where id = old.recid;

    return old;
end;
$$ language plpgsql;

create trigger rhn_probe_delete_trigger before delete on rhn_probe
for each row
execute procedure rhn_probe_delete_trigger_fun();

create or replace function time_series_purge_mod_trig_fun() returns trigger as
$$
begin
    new.modified := current_timestamp;
    return new;
end;
$$ language plpgsql;

create trigger time_series_purge_mod_trig before insert or update on time_series_purge
for each row
execute procedure time_series_purge_mod_trig_fun();

-- migration from time_series to time_series_data
insert into time_series_data (org_id, probe_id, probe_desc, entry_time, data) (
    select t_ts.*
      from (
            select split_part(ts.o_id, '-', 1) :: numeric,
                   split_part(ts.o_id, '-', 2) :: numeric as probe_id,
                   split_part(ts.o_id, '-', 3),
                   ts.entry_time,
                   ts.data
              from time_series ts
           ) t_ts, rhn_probe rp
     where t_ts.probe_id :: numeric = rp.recid
);

drop table time_series;

-- compatibility time_series view
create or replace view time_series as (
    select tsd.org_id || '-' || tsd.probe_id || '-' || tsd.probe_desc as o_id,
           tsd.entry_time as entry_time,
           tsd.data as data
      from time_series_data tsd
    );
