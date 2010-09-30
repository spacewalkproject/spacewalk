-- oracle equivalent source sha1 d076463bb8216d1c581993d462e607ad60ca4066
-- retrieved from ./1241057068/d2f16725f65bddae85cd4782cd82e0c84c0a776d/schema/spacewalk/oracle/procs/sequence_nextval.sql
create or replace function
sequence_nextval( seq_name regclass ) returns bigint as
$$
	select nextval($1);
$$ language sql;
