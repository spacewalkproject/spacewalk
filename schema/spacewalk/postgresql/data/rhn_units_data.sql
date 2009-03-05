--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--
-- 
--

--data for rhn_units

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('secs','time','sec','Seconds',
    'x','x','is_number(x)','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('percent','none','%','Percentage',
    'x','x','is_number(x)  and 0 <= x <= 100','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('bits','data','B','Bits',
    'x/8','x*8','is_integer(x) and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('count','none',NULL,'Number',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('astring','none',NULL,'ASCII string',
    'x','x','is_ascii(x)','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('Bps','datarate','bits/sec','Bits per second',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('hertz','frequency','hz','Cycles per second',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('kelvins','temp','K','Degrees Kelvin',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('kilograms','mass','kg','Kilograms',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('amperes','current','A','Amperes',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('newtons','force','N','Newtons',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('watts','power','W','Watts',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('coulombs','charge','C','Coulombs',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('volts','voltage','V','Volts',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('rpm','frequency','rpm','Revolutions per minute',
    'x*60','x/60','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('MHz','frequency','MHz','Megahertz',
    'x*1024*1024','x/1024/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('bps','datarate','bytes/sec','Bytes per second',
    'x*8','x/8','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('kBps','datarate','Kbits/sec','Kilobits per second',
    'x*1024','x/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('MBps','datarate','Mbits/sec','Megabits per second',
    'x*1024*1024','x/1024/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('bytes','data','bytes','Bytes',
    'x','x','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('kb','data','Kbytes','Kilobytes',
    'x*1024','x/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('Mb','data','MB','Megabytes',
    'x*1024*1024','x/1024/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('Gb','data','GB','Gigabytes',
    'x*1024*1024*1024','x/1024/1024/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('kW','power','kW','Kilowatts',
    'x*1024','x/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('millisecs','time','ms','Milliseconds',
    'x*1000','x/1000','is_number(x)','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('boolean','none',NULL,'Boolean',
    'x','x','is_boolean(x)','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('eps','frequency','/sec','Events per second',
    NULL,NULL,NULL,'system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('celsius','temp','C','Degrees Celsius',
    'x+273','x-273','is_number(x) and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('metres','length','m','Metres',
    'x','x','is_number(x) and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('epm','frequency','/min','Events per minute',
    'x/60','x*60','is_number(x) and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('Kbps','datarate','Kbytes/sec','Kilobytes per second',
    'x*8*1024','x/8/1024','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('bpm','datarate','bytes/min','Bytes per minute',
    'x*8','x/8','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('lpm','datarate','lines/min','Lines per minute',
    NULL,NULL,'is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('pounds','mass','lb','Pounds',
    'x * 0.4535924','x / 0.4535924','is_number(x)  and x >= 0','system',current_timestamp);

insert into rhn_units(unit_id,quantum_id,unit_label,description,
to_base_unit_fn,from_base_unit_fn,validate_fn,last_update_user,last_update_date)
    values ('msps','datarate','millisec/sec','Milliseconds per second',
    'x','x','is_number(x) and x >= 0','system',current_timestamp);

--
--Revision 1.4  2004/06/17 20:48:59  kja
--bugzilla 124970 -- _data is in for 350.
--
--Revision 1.3  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 17:49:49  kja
--Added data for the reference tables.
--
