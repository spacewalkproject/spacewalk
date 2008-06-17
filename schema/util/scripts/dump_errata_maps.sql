-- Script that dumps the channel maps
--
-- Use it like:
--
-- sqlplus -S user/pass@db @dump_errata_maps.sql > /tmp/channel-maps.csv < /dev/null
--
-- $Id$

set pagesize 0
set linesize 256
set feedback off
column x format A256

select c.label || ',' || bpm.path || ',' || nvl2(is_source, 'Y', '') x
from rhnBeehivePathMap bpm, rhnPathChannelMap pcm, rhnChannel c
where bpm.ftp_path = pcm.path
and pcm.channel_id = c.id
order by c.label, bpm.path;
