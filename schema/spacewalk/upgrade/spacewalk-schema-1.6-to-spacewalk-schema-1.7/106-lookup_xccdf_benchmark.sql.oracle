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

create or replace function
lookup_xccdf_benchmark(identifier_in in varchar2, version_in in varchar2)
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
show errors
