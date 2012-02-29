-- oracle equivalent source sha1 3dabe623b63fab475d78d78d1169b2b380f14655

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
        begin
            perform pg_dblink_exec(
                'insert into rhnXccdfBenchmark (id, identifier, version) values (' ||
                benchmark_id || ', ' ||
                coalesce(quote_literal(identifier_in), 'NULL') || ', ' ||
                coalesce(quote_literal(version_in), 'NULL') || ')');
        exception when unique_violation then
            select id
              into strict benchmark_id
              from rhnXccdfBenchmark
             where identifier = identifier_in and version = version_in;
        end;
    end if;

    return benchmark_id;
end;
$$ language plpgsql immutable;
