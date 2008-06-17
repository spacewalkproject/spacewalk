set newpage none
set pagesize 1000
set wrap off
set linesize 80
set head on

column cpu_model format a45
column device_desc format a60

--create or replace function
--rhnCpuSpeedRangeFunc(speed NUMBER)
--return VARCHAR2
--deterministic 
--as 
--    begin 
--        return trunc(speed/100)*100 || ' - ' || (trunc(speed/100)+1)*100;
--    end; 
--/
--show errors

--select
--    DECODE(GROUPING(model), 1, 'All Models', model) "CPU Model",
--    DECODE(GROUPING(rhnCpuSpeedRangeFunc(mhz)), 1, 'All Speeds', 
--	   rhnCpuSpeedRangeFunc(mhz)) "CPU Speed",
--    count(id) "Number Profiles"
--from 
--    rhnCPU
--group by ROLLUP(model, rhnCpuSpeedRangeFunc(mhz));

-- report on the CPUs
select 'Registration data for PROCESSOR' report from dual;
select
    model cpu_model,
    count(id) cpu_count,
    round(avg(mhz)) avg_speed
from
    rhnCPU
group by
    model
order by
    cpu_count desc;

-- report the ram
select 'Registration data for MEMORY' report from dual;
select
    ram ram_size,
    count(id) no_profiles
from 
    rhnRAM
group by ram
order by ram_size desc;

-- report the video cards
select 'Registration data for VIDEO cards' report from dual;
select
    upper(description) device_desc,
    count(id) device_count
from
    rhnDevice
where
    class = 'VIDEO'
group by
    upper(description)
order by
    device_desc;

-- scsi
select 'Registration data for SCSI cards' report from dual;
select
    upper(description) device_desc,
    count(id) device_count
from
    rhnDevice
where
    class = 'SCSI'
group by
    upper(description)
order by
    device_desc;

-- networking
select 'Registration data for NETWORK cards' report from dual;
select
    upper(description) device_desc,
    count(id) device_count
from
    rhnDevice
where
    class = 'NETWORK'
group by
    upper(description)
order by
    device_desc;

-- audio
select 'Registration data for AUDIO cards' report from dual;
select
    upper(description) device_desc,
    count(id) device_count
from
    rhnDevice
where
    class = 'AUDIO'
group by
    upper(description)
order by
    device_desc;
