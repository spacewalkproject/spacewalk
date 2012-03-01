-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

create or replace function
create_pxt_session(p_web_user_id in numeric, p_expires in numeric, p_value in varchar)
returns numeric as $$
declare
	l_id numeric;
begin
    l_id := nextval( 'pxt_id_seq' );

    perform pg_dblink_exec(
        'insert into PXTSessions (id, value, expires, web_user_id) values (' ||
        l_id || ', ' || ', ' || coalesce(quote_literal(p_value), 'NULL') ||
        ', ' || ', ' || p_expires || ', ' || p_web_user_id || '); commit');

	return l_id;
end;
$$ language plpgsql;
