-- oracle equivalent source sha1 8cb4b4ce75b5de5afefb3ce0306453e7beb9ebd3
--
-- Take seconds since epoch (January 1, 1970 UTC) and convert it
-- to time-zone'd timestamp. Mainly as compatibility with Oracle
-- which does not have the single-parameter to_timestamp.
--

create function epoch_seconds_to_timestamp_tz(secs in numeric)
returns timestamp with time zone
as
$$
begin
	return to_timestamp(secs);
end;
$$ language plpgsql;

