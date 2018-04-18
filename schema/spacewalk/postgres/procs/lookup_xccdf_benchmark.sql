-- oracle equivalent source sha1 9491baee899b1ae99ac039939eed51f7b5bc0342
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

create or replace function
lookup_xccdf_benchmark(identifier_in in varchar, version_in in varchar)
returns numeric
as
$$
declare
    benchmark_id numeric;
begin
    select id
      into benchmark_id
      from rhnXccdfBenchmark
     where identifier = identifier_in and version = version_in;

    if not found then
        benchmark_id := nextval('rhn_xccdf_benchmark_id_seq');

        insert into rhnXccdfBenchmark (id, identifier, version)
            values (benchmark_id, identifier_in, version_in)
            on conflict do nothing;

        select id
            into strict benchmark_id
            from rhnXccdfBenchmark
            where identifier = identifier_in and version = version_in;
    end if;

    return benchmark_id;
end;
$$ language plpgsql;
