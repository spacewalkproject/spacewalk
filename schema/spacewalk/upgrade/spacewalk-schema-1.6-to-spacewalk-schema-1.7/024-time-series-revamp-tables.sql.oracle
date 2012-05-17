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

create or replace trigger time_series_purge_mod_trig
before insert or update on time_series_purge
for each row
begin
    :new.modified := sysdate;
end;
/

-- populate time_series_purge with values from rhn_probe
insert into time_series_purge (id, probe_id, deleted) (select rp.recid, rp.recid, 0 from rhn_probe rp);
commit;

create table time_series_data
(
    org_id      number not null,
    probe_id    number not null
                    constraint time_series_data_pid_fk references
                    time_series_purge(id),
    probe_desc  varchar2(64),
    entry_time  number not null,
    data        varchar2(1024)
)
enable row movement;

create index time_series_data_pid_time_idx on time_series_data(probe_id, entry_time)
  tablespace [[64k_tbs]]
  nologging;

-- triggers
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

-- migration from time_series to time_series_data
declare
    cur_rec_id number;
    pre_rec_id number;
    max_rec_id number;
begin
    select max(recid) into max_rec_id
      from rhn_probe;

	if max_rec_id is null then
		return;
    end if;

    pre_rec_id := 0;

    loop
        select min(recid) into cur_rec_id
          from rhn_probe
         where recid > pre_rec_id;

        insert /*+ append */ into time_series_data (org_id, probe_id, probe_desc, entry_time, data) (
            select t_ts.*
              from (select substr(ts.o_id, 1, instr(ts.o_id, '-', 1, 1) - 1),
                           substr(ts.o_id,
                                  instr(ts.o_id, '-') + 1,
                                  (instr(ts.o_id,
                                         '-',
                                         instr(ts.o_id, '-') + 1) -
                                   instr(ts.o_id, '-')) - 1
                                 ) as probe_id,
                           substr(ts.o_id, instr(ts.o_id, '-', 1, 2) + 1),
                           ts.entry_time,
                           ts.data
                      from time_series ts
                   ) t_ts
             where t_ts.probe_id = to_char(cur_rec_id)
        );
        commit;

        exit when cur_rec_id = max_rec_id;

        pre_rec_id := cur_rec_id;
    end loop;
end;
/

-- drop old time_series
drop table time_series;

-- compatibility view
create or replace view time_series as (
    select tsd.org_id || '-' || tsd.probe_id || '-' || tsd.probe_desc as o_id,
           tsd.entry_time as entry_time,
           tsd.data as data
      from time_series_data tsd
    );
