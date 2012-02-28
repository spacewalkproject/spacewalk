create or replace function insert_evr(e_in in varchar2, v_in in varchar2, r_in in varchar2)
return number
is
    pragma autonomous_transaction;
    evr_id  number;
begin
    insert into rhnPackageEVR(id, epoch, version, release, evr)
    values (rhn_pkg_evr_seq.nextval,
            e_in,
            v_in,
            r_in,
            evr_t(e_in, v_in, r_in)) returning id into evr_id;
    commit;
    return evr_id;
end;
/
show errors

create or replace function
lookup_evr(e_in in varchar2, v_in in varchar2, r_in in varchar2)
return number
is
    evr_id  number;
begin
    select id
      into evr_id
      from rhnPackageEVR
    where ((epoch is null and e_in is null) or (epoch = e_in)) and
          version = v_in and
          release = r_in;

    return evr_id;
exception when no_data_found then
    begin
        evr_id := insert_evr(e_in, v_in, r_in);
    exception when dup_val_on_index then
        select id
          into evr_id
          from rhnPackageEVR
        where ((epoch is null and e_in is null) or (epoch = e_in)) and
              version = v_in and
              release = r_in;
    end;

	return evr_id;
end;
/
show errors
