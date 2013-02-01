--
-- Take seconds since epoch (January 1, 1970 UTC) and convert it
-- to time-zone'd timestamp.
--

create or replace function epoch_seconds_to_timestamp_tz(secs in number)
return timestamp with local time zone
is
begin
	return to_timestamp_tz('1970-01-01 00:00:00 UTC', 'YYYY-MM-DD HH24:MI:SS TZR') + numtodsinterval(secs, 'second');
end;
/
show errors

