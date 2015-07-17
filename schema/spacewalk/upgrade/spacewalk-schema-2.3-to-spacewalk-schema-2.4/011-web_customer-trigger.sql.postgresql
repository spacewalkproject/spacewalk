-- oracle equivalent source sha1 cef5ccbf2ce16fc72d7491f2ba9a3f79e32453de

create or replace function web_customer_insert_trig_fun() returns trigger
as
$$
begin
	insert into rhnOrgConfiguration (org_id) values (new.id);
	insert into rhnOrgAdminManagement (org_id) values (new.id);

        return new;
end;
$$
language plpgsql;
