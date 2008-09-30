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

--data for rhn_time_zone_names (no sequence)

insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 10,'America/Anchorage','US/Alaska',-540,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 20,'America/Chicago','US/Central',-360,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 30,'America/Denver','US/Mountain',-420,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 40,'America/Halifax','Canada/Atlantic',-240,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 50,'America/Indianapolis','US/Indiana',-300,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 60,'America/Los_Angeles','US/Pacific',-480,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 70,'America/New_York','US/Eastern',-300,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 80,'America/Phoenix','US/Arizona',-420,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 90,'America/St_Johns','Canada/Newfoundland',-210,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 100,'Europe/Bucharest','Europe/Eastern',120,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 110,'Europe/Paris','Europe/Central',60,'1','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 120,'GMT','Greenwich Mean Time',0,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 130,'Pacific/Honolulu','US/Hawaii',-600,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 150,'America/Puerto_Rico','Puerto Rico',-240,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 160,'Europe/Moscow','Europe/Moscow',180,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 170,'Asia/Hong_Kong','Asia/Hong Kong',480,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 180,'Asia/Shanghai','Asia/Shanghai',480,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 190,'Asia/Singapore','Asia/Singapore',480,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 200,'Asia/Taipei','Asia/Taipei',480,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 210,'Asia/Seoul','Asia/Seoul',540,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 220,'Asia/Tokyo','Asia/Tokyo',540,'0','system',
    sysdate);
insert into rhn_time_zone_names(recid,java_id,display_name,gmt_offset_minutes,
use_daylight_time,last_update_user,last_update_date) 
    values ( 230,'Australia/Sydney','Australia/Sydney',600,'0','system',
    sysdate);
commit;

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
