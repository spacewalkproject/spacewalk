-- oracle equivalent source sha1 5cac57e2eb784ae8a4f66d945ca38110ce6497b4
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

-- create schema logging;

update pg_settings set setting = 'logging,' || setting where name = 'search_path';

create or replace function clear_log_id()
returns void
as
$$
    global the_log_id
    set the_log_id 0
    global the_user_id
    set the_user_id 0
    global the_stamp
    set the_stamp ""
    return
$$ language pltclu set search_path from current;

create or replace function _set_log_auth(user_id in integer, stamp in varchar)
returns void
as
$$
    global the_user_id
    set the_user_id $1
    global the_stamp
    set the_stamp $2
$$ language pltclu set search_path from current;

create or replace function set_log_auth(user_id in integer)
returns void
as
$$
begin
    perform _set_log_auth(user_id, current_timestamp::varchar);
end
$$ language plpgsql set search_path from current;

create or replace function _get_log_auth()
returns integer
as
$$
    global the_user_id
    return $the_user_id
$$ language pltclu set search_path from current;

create or replace function _get_log_stamp()
returns varchar
as
$$
    global the_stamp
    return $the_stamp
$$ language pltclu set search_path from current;

create or replace function _get_log_id()
returns integer
as
$$
    global the_log_id
    return $the_log_id
$$ language pltclu set search_path from current;

create or replace function _set_log_id(log_id in integer)
returns void
as
$$
    global the_log_id
    set the_log_id $1
    return
$$ language pltclu set search_path from current;

create or replace function get_log_id()
returns integer
as
$$
declare
    the_log_id integer;
    the_user_id integer;
    the_stamp varchar;
begin
    the_log_id := _get_log_id();
    if the_log_id is not null and the_log_id > 0 then return the_log_id ; end if;
    the_log_id := nextval('log_seq');
    the_user_id := _get_log_auth();
    the_stamp := _get_log_stamp();
    insert into public.log (id, stamp, user_id)
    values (the_log_id,
        case when the_stamp = '' then current_timestamp else the_stamp::timestamp with time zone end,
        case when the_user_id = '0' then null else the_user_id::integer end);
    perform _set_log_id(the_log_id);
    return the_log_id;
end;
$$ language plpgsql set search_path from current;

create or replace function enable_logging(table_name_in in varchar)
returns void
as
$$
declare
    pk_column varchar;
    ddl_columns varchar;
    the_insert varchar;
    rec record;
begin
    select constraint_column_usage.column_name into strict pk_column
    from information_schema.table_constraints, information_schema.constraint_column_usage
    where constraint_column_usage.table_catalog = current_catalog
        and constraint_column_usage.table_schema = 'public'
        and constraint_column_usage.table_name = table_name_in
        and constraint_column_usage.constraint_catalog = current_catalog
        and constraint_column_usage.constraint_schema = 'public'
        and constraint_column_usage.table_catalog = table_constraints.constraint_catalog
        and constraint_column_usage.table_catalog = table_constraints.table_catalog
        and constraint_column_usage.table_schema = table_constraints.constraint_schema
        and constraint_column_usage.table_schema = table_constraints.table_schema
        and constraint_column_usage.constraint_catalog = table_constraints.constraint_catalog
        and constraint_column_usage.constraint_name = table_constraints.constraint_name
        and table_constraints.constraint_type = 'PRIMARY KEY';
    ddl_columns := '';
    for rec in (
        select column_name
        from information_schema.columns
        where table_catalog = current_catalog
            and table_schema = 'public'
            and table_name = table_name_in
            and column_name not in ( pk_column, 'created', 'modified' )
    ) loop
        ddl_columns := ddl_columns || ', ' || rec.column_name;
    end loop;

    execute 'create table public.' || table_name_in || '_log
        as select ' || pk_column || ', logging.get_log_id()::integer as log_id, ''A''::char as action' || ddl_columns
        || ' from ' || table_name_in;
    execute 'alter table public.' || table_name_in || '_log alter ' || pk_column || ' set not null';
    execute 'create index ' || table_name_in || '_log_idx on public.' || table_name_in || '_log(' || pk_column || ')';
    execute 'alter table public.' || table_name_in || '_log alter log_id set not null';
    execute 'alter table public.' || table_name_in || '_log add foreign key (log_id) references log(id)';
    execute 'alter table public.' || table_name_in || '_log alter action set not null';

    the_insert := 'insert into public.' || table_name_in || '_log (log_id, action, ' || pk_column || ddl_columns ||')
                values (log_id_v, substr(tg_op, 1, 1)' || replace(', ' || pk_column || ddl_columns, ', ', ', old.') || ');';
    execute 'create or replace function public.' || table_name_in || '_log_trig_fun() returns trigger as
        ''
        declare
            log_id_v integer;
        begin
            log_id_v := logging.get_log_id();
            if tg_op = ''''UPDATE'''' then
                if old.' || pk_column || ' <> new.' || pk_column || ' then raise exception ''''Cannot update column ' || table_name_in || '.' || pk_column || '.''''; end if;
            end if;
            if tg_op = ''''DELETE'''' then
                ' || the_insert || '
            else
                ' || replace(the_insert, 'old.', 'new.') || '
            end if;
            return new;
        end;
        ''
        language plpgsql;';

    execute 'create trigger ' || table_name_in || '_log_trig
        after insert or update or delete on public.' || table_name_in || '
        for each row
        execute procedure ' || table_name_in || '_log_trig_fun()';

end;
$$
language plpgsql;

update pg_settings set setting = overlay( setting placing '' from 1 for (length('logging')+1) ) where name = 'search_path';
