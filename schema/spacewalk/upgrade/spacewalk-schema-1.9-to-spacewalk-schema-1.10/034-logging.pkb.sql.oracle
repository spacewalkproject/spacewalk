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

create or replace package body logging
is
    the_log_id integer;
    the_user_id integer;
    the_stamp timestamp with local time zone;
    procedure clear_log_id
    is
    begin
        the_log_id := null;
        the_user_id := null;
        the_stamp := current_timestamp;
    end clear_log_id;
    procedure set_log_auth(user_id in integer)
    is
    begin
        if the_stamp is null then
        raise_application_error(-20299, 'Call set_log_auth need to follow clear_log_id.');
        end if;
        the_user_id := user_id;
        the_stamp := current_timestamp;
    end set_log_auth;
    function get_log_id return number
    is
    begin
        if the_stamp is null then
        raise_application_error(-20297, 'Call get_log_id need to follow set_log_auth.');
        end if;
        if the_log_id is null then
        insert into log (id, stamp, user_id)
        values (log_seq.nextval, the_stamp, the_user_id)
            returning id into the_log_id;
        end if;
        return the_log_id;
    end get_log_id;

procedure enable_logging(table_name_in in varchar)
is
    pk_column varchar(512);
    ddl_columns varchar(4000);
    the_insert varchar(4000);
    already_not_null exception;
    pragma exception_init(already_not_null, -1442);
begin
    select column_name into pk_column
    from user_cons_columns
    where constraint_name = (
        select constraint_name
        from user_constraints
        where table_name = upper(table_name_in)
            and constraint_type = 'P'
            and owner = user
        )
        and owner = user ;
    ddl_columns := '';
    for rec in (
        select column_name
        from user_tab_columns
        where table_name = upper(table_name_in)
            and column_name not in ( pk_column, 'CREATED', 'MODIFIED' )
        order by column_id
    ) loop
        ddl_columns := ddl_columns || ', ' || rec.column_name;
    end loop;

    execute immediate 'create table ' || table_name_in || '_log
        as select ' || pk_column || ', logging.get_log_id() as log_id, ''A'' as action' || ddl_columns
        || ' from ' || table_name_in;
    begin
        execute immediate 'alter table ' || table_name_in || '_log modify ' || pk_column || ' not null';
    exception when already_not_null then
        null;
    end;
    execute immediate 'create index ' || table_name_in || '_log_idx on ' || table_name_in || '_log(' || pk_column || ')';
    execute immediate 'alter table ' || table_name_in || '_log modify log_id not null';
    execute immediate 'alter table ' || table_name_in || '_log add foreign key (log_id) references log(id)';
    execute immediate 'alter table ' || table_name_in || '_log modify action not null';

    the_insert := 'insert into ' || table_name_in || '_log (log_id, action, ' || pk_column || ddl_columns ||')
                values (log_id_v, substr(tg_op, 1, 1)' || replace(', ' || pk_column || ddl_columns, ', ', ', :old.') || ');';
    execute immediate 'create or replace trigger ' || table_name_in || '_log_trig
        after insert or update or delete on ' || table_name_in || '
        for each row
        declare
            log_id_v integer;
            tg_op char(1);
        begin
            log_id_v := logging.get_log_id();
            if updating then
                if :old.' || pk_column || ' <> :new.' || pk_column || ' then raise_application_error(-20298, ''Cannot update column ' || table_name_in || '.' || pk_column || '.''); end if;
                tg_op := ''U'';
            end if;
            if deleting then
                    tg_op := ''D'';
                ' || the_insert || '
            else
                if inserting then tg_op := ''I''; end if;
                ' || replace(the_insert, ':old.', ':new.') || '
            end if;
        end;
        ';
end enable_logging;
end logging;
/
show errors
