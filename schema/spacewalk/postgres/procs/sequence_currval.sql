create or replace function
sequence_currval( seq_name regclass ) returns bigint as
$$
	select currval($1);
$$ language sql;
