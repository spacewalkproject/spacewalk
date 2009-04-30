create or replace function
sequence_nextval( seq_name regclass ) returns bigint as
$$
	select nextval($1);
$$ language sql;
