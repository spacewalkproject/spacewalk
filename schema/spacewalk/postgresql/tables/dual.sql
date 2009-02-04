create table dual ( dummy char );

insert into dual values ( 'X' );

create or replace rule deny_insert_dual as on insert to dual do instead nothing;
create or replace rule deny_update_dual as on update to dual do instead nothing;
create or replace rule deny_delete_dual as on delete to dual do instead nothing;

