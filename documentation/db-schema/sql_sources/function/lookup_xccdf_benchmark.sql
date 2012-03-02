-- created by Oraschemadoc Fri Mar  2 05:58:13 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_XCCDF_BENCHMARK" (identifier_in in varchar2, version_in in varchar2)
return number
is
    benchmark_id    number;
begin
    select id
      into benchmark_id
      from rhnXccdfBenchmark
     where identifier = identifier_in and version = version_in;
    return benchmark_id;
exception when no_data_found then
    begin
        benchmark_id := insert_xccdf_benchmark(identifier_in, version_in);
    exception when dup_val_on_index then
        select id
          into benchmark_id
          from rhnXccdfBenchmark
         where identifier = identifier_in and version = version_in;
    end;
    return benchmark_id;
end lookup_xccdf_benchmark;
 
/
