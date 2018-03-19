-- oracle equivalent source sha1 3b515f6f0bfa8c168ebe0351d58c5d4df4d92108

drop function rhn_channel.set_comps(channel_id_in in numeric, path_in in varchar, timestamp_in in varchar);

create or replace function rhn_channel.set_comps(channel_id_in in numeric, path_in in varchar, comps_type_id_in in numeric, timestamp_in in varchar) returns void
as $$
declare
row record;
begin
  for row in (
    select relative_filename, last_modified
      from rhnChannelComps
      where channel_id = channel_id_in
      and comps_type_id = comps_type_id_in
      ) loop
      if row.relative_filename = path_in
        and row.last_modified = to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS') then
        return;
      end if;
    end loop;
    delete from rhnChannelComps
    where channel_id = channel_id_in and comps_type_id = comps_type_id_in;
    insert into rhnChannelComps (id, channel_id, relative_filename, comps_type_id, last_modified, created, modified)
    values (sequence_nextval('rhn_channelcomps_id_seq'), channel_id_in, path_in, comps_type_id_in, to_timestamp(timestamp_in, 'YYYYMMDDHH24MISS'), current_timestamp, current_timestamp);
end$$ language plpgsql;
