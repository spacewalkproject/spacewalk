-- oracle equivalent source none

create function no_operation_trig_fun()
returns trigger as
$$
begin
	raise exception 'Permission denied: % is not allowed on %', TG_OP, TG_RELNAME;
end;
$$ language plpgsql;

