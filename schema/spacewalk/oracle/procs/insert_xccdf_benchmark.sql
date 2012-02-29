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

create or replace function insert_xccdf_benchmark(identifier_in in varchar2, version_in in varchar2)
return number
is
    pragma autonomous_transaction;
    benchmark_id    number;
begin
    insert into rhnXccdfBenchmark (id, identifier, version)
    values (rhn_xccdf_benchmark_id_seq.nextval, identifier_in, version_in) returning id into benchmark_id;
    commit;
    return benchmark_id;
end;
/
show errors
