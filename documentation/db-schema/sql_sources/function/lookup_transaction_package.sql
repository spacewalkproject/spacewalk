-- created by Oraschemadoc Fri Mar  2 05:58:12 2012
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FUNCTION "SPACEWALK"."LOOKUP_TRANSACTION_PACKAGE" (
    o_in in varchar2,
    n_in in varchar2,
    e_in in varchar2,
    v_in in varchar2,
    r_in in varchar2,
    a_in in varchar2)
return number
is
    pragma autonomous_transaction;
    o_id        number;
    n_id        number;
    e_id        number;
    p_arch_id   number;
    tp_id       number;
begin
    begin
        select id
          into o_id
          from rhnTransactionOperation
         where label = o_in;
    exception when no_data_found then
        rhn_exception.raise_exception('invalid_transaction_operation');
    end;

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
    return tp_id;
exception when no_data_found then
    begin
        tp_id := insert_transaction_package(o_id, n_id, e_id, p_arch_id);
    exception when dup_val_on_index then
        select id
          into tp_id
          from rhnTransactionPackage
         where operation = o_id and
               name_id = n_id and
               evr_id = e_id and
               (package_arch_id = p_arch_id or (p_arch_id is null and package_arch_id is null));
    end;
    return tp_id;
end;
 
/
