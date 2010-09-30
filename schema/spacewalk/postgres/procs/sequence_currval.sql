-- oracle equivalent source sha1 302e8f7ae0156526bd911e40ddfdbd807b0bb25b
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/sequence_currval.sql
create or replace function
sequence_currval( seq_name regclass ) returns bigint as
$$
	select currval($1);
$$ language sql;
