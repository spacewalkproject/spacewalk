create or replace function sequence_nextval( seq_name regclass ) returns numeric as
$$
	select nextval( $1 )::numeric;
$$ language sql;

