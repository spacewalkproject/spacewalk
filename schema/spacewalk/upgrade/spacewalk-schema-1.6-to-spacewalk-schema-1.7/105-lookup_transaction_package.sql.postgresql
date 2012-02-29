-- oracle equivalent source sha1 95bcebe5c82f6192aff713976e6b77cffbba54c3

create or replace function
lookup_transaction_package(
    o_in in varchar,
    n_in in varchar,
    e_in in varchar,
    v_in in varchar,
    r_in in varchar,
    a_in in varchar)
returns numeric
as
$$
declare
    o_id        numeric;
    n_id        numeric;
    e_id        numeric;
    p_arch_id   numeric;
    tp_id       numeric;
begin
    select id
      into o_id
      from rhnTransactionOperation
     where label = o_in;

    if not found then
        perform rhn_exception.raise_exception('invalid_transaction_operation');
    end if;

    n_id := lookup_package_name(n_in);
    e_id := lookup_evr(e_in, v_in, r_in);
    p_arch_id := null;

    if a_in is not null then
        p_arch_id := lookup_package_arch(a_in);
    end if;

    select id
      into tp_id
      from rhnTransactionPackage
     where operation = o_id and
           name_id = n_id and
           evr_id = e_id and
           (package_arch_id = p_arch_id or (p_arch_id is null and package_arch_id is null));

    if not found then
        tp_id := nextval('rhn_transpack_id_seq');
        begin
            perform pg_dblink_exec(
                'insert into rhnTransactionPackage (id, operation, name_id, evr_id, package_arch_id)' ||
                ' values (' || tp_id || ', ' || o_id || ', ' || n_id || ', ' || e_id ||
                ', ' || ', ' || p_arch_id  || ')');
        exception when unique_violation then
            select id
              into strict tp_id
              from rhnTransactionPackage
             where operation = o_id and
                   name_id = n_id and
                   evr_id = e_id and
                   (package_arch_id = p_arch_id or (p_arch_id is null and package_arch_id is null));
        end;
    end if;

    return tp_id;
end;
$$
language plpgsql immutable;
