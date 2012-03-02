-- oracle equivalent source sha1 cb07e6926fb5f79d7645be270e632f9168631964
--
-- Copyright (c) 2010--2012 Red Hat, Inc.
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
-- empty varchars are not allowed for the oracle-postgres compatibility
-- create constraints on all varchar columns (all tables for the current user)
-- and returns number of errors during processing (if not 0 then
-- check the pgsql log -- usually /var/lib/pgsql/data/pg_log -- for errors)
--
create or replace function create_varnull_constriants() returns integer as $$
declare
    tabs record;
    total integer default 0;
begin

    for tabs in select 
        c.relname as "tab",
        a.attname as "col"
    from
        pg_catalog.pg_attribute a
        left outer join pg_catalog.pg_class c on a.attrelid = c.oid 
    where
        -- skip system columns
        a.attnum > 0
        -- skip dropped columns
        and not a.attisdropped
        -- filter only varchars
        and a.atttypid = 1043
        -- skip cols that already has this constraint
        and not exists (
            select 1 from pg_catalog.pg_constraint 
            where conname = 'vn_' || c.relname || '_' || a.attname
        )
        -- filter only tables owned by current user
        and a.attrelid in (
            select c.oid from pg_catalog.pg_class c
            where relkind = 'r' and pg_catalog.pg_table_is_visible(c.oid) and relowner = (
                select oid from pg_catalog.pg_authid where rolname = current_user
            )
        ) loop
        begin
            -- create constraint
            execute 'alter table ' || tabs.tab || ' add constraint vn_' ||
                tabs.tab || '_' || tabs.col || ' check (' || tabs.col || ' <> '''')';
            -- count them
        exception when others then
            total = total + 1;
            raise warning '% unable to create constraint for %.%', now(), tabs.tab, tabs.col;
        end;
    end loop;

    return total;
end;
$$ language plpgsql;

select create_varnull_constriants();


