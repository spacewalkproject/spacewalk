create or replace function sequence_currval( seq_name regclass ) returns numeric as
$$
	select currval( $1 )::numeric;
$$ language sql;

