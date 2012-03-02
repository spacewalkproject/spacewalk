-- created by Oraschemadoc Fri Mar  2 05:58:11 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."INSERT_XCCDF_BENCHMARK" (identifier_in in varchar2, version_in in varchar2)
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
