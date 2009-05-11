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
--data for rhn_command_parameter
--command parameters for linux and scouts only


insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'r_tproto_0','config','string','r_tproto_0','1','tcp',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'r_svc_0','config','string','r_svc_0','1','BAD_FIXME',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'r_port_0','config','integer','Port','1','1',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'send','config','string','Send','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'expect','config','string','Expect','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 6,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'sat_0','config','string','sat_0','1','$SAT$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'r_tproto_0','config','string','r_tproto_0','1','udp',NULL,NULL,3,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,4,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'r_svc_0','config','string','r_svc_0','1','BAD_FIXME',NULL,NULL,5,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'r_port_0','config','integer','Port','1','1',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'send','config','string','Send','0',NULL,NULL,NULL,7,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'expect','config','string','Expect','0',NULL,NULL,NULL,8,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 7,'timeout','config','integer','Timeout (seconds)','0','10',NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 8,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 8,'r_port_0','config','integer','SMTP Port','1','25',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 8,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 8,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 8,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'r_ip_0','config','string','hostaddress','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'r_port_0','config','integer','Port','1','110',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 9,'expect','config','generic','Expect','1','+OK',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,80,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'r_port_0','config','integer','FTP Port','1','21',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'expect_content','config','generic','Expect','0','FTP',NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'username','config','string','Username','0',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 10,'password','config','password','Password','0',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,120,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'r_port_0','config','integer','HTTP Port','1','80',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'expect_header','config','string','Expect Header','0','HTTP/1',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'url','config','string','URL Path','0','/',NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'expect_content','config','string','Expect Content','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'virtual_host','config','string','Virtual Host','0',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'useragent','config','string','UserAgent','1','NOCpulse-check_http/1.0',NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'username','config','string','Username','0',NULL,NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 11,'password','config','password','Password','0',NULL,NULL,NULL,70,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'ip','config','generic','IP Address (optional; defaults to host IP)','0',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'warn_time','threshold','integer','Warning Round-trip Ave','0','10',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'warn_loss','threshold','integer','Warning Packet Loss Pct','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'critical_time','threshold','integer','Critical Round-trip Ave','0','15',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'critical_loss','threshold','integer','Critical Packet Loss Pct','0','15',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'packets','config','integer','Packets to send','1','20',1,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 13,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 14,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,4,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 14,'lookuphost','config','string','Host or Address to Look Up','1','www.redhat.com',NULL,NULL,5,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 14,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 15,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 15,'timeout','config','integer','Timeout (seconds)','1','5',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 15,'r_port_0','config','integer','SSH Port','1','22',NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'port_0','config','integer','SNMP Port','1','161',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'oid_0','config','string','SNMP OID','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'version','config','string','SNMP Version','1','2',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'community','config','password','SNMP Community String','1','public',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'genericGTwarning','threshold','integer','Warning Value','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'genericGTcritical','threshold','integer','Critical Value','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'genericLTwarning','threshold','integer','Warning Value','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'genericLTcritical','threshold','integer','Critical Value','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'warn','threshold','float','Warn Percent','0','85',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'critical','threshold','float','Critical Percent','0','95',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'fs_0','config','string','Device','1','/dev/hda1',NULL,NULL,3,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 18,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 18,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 18,'warn','threshold','integer','Warn Users','0','1',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 18,'critical','threshold','integer','Critical Users','0','2',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 19,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 19,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 19,'warn','threshold','integer','Warn Processes','0','500',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 19,'critical','threshold','integer','Critical Processes','0','900',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'warn1','threshold','float','Warn 1 min','0','4',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'warn5','threshold','float','Warn 5 min','0','4',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'warn15','threshold','float','Warn 15 min','0','3',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'critical1','threshold','float','Critical 1 min','0','8',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'critical5','threshold','float','Critical 5 min','0','6',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 20,'critical15','threshold','float','Critical 15 min','0','5',NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 22,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 22,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 22,'swap_0','config','string','swap_0','1','swap',NULL,NULL,3,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 22,'warn','threshold','integer','Warning Swap Pct Free','0',NULL,NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 22,'critical','threshold','integer','Critical Swap Pct Free','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'ip','config','string','IP Address','1','$HOSTADDRESS$',NULL,NULL,60,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'ORACLE_HOME','config','string','ORACLE_HOME variable','1','/opt/oracle',NULL,NULL,50,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'port','config','integer','TNS Listener Port','1','1521',NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'warn_latency','threshold','float','Warning Latency','0',NULL,NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 23,'critical_latency','threshold','float','Critical Latency','0',NULL,NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 24,'w_latency','threshold','integer','Warning Seconds','0','6',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 24,'c_latency','threshold','integer','Critical Seconds','0','10',NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (25, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (25, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'warn','threshold','float','Warning RAM Free','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'critical','threshold','float','Critical RAM Free','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'reclaim','config','checkbox','Include reclaimable memory','0','0',NULL,NULL,40,'checkbox',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (26, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (26, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'warn','threshold','integer','Warning CPU Pct Used','0','70',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'critical','threshold','integer','Critical CPU Pct Used','0','90',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'warn1','threshold','float','Warning CPU Load 1-Min Ave','0',NULL,NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'critical1','threshold','float','Critical CPU Load 1-Min Ave','0',NULL,NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'warn15','threshold','float','Warning CPU Load 15-Min Ave','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'critical15','threshold','float','Critical CPU Load 15-Min Ave','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (27, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 31, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (27, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'warn5','threshold','float','Warning CPU Load 5-Min Ave','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'critical5','threshold','float','Critical CPU Load 5-Min Ave','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (28, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 35, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (28, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 45, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'timeout','config','integer','Timeout (seconds)','1','20',0,300,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'warn','threshold','integer','Warning Swap Pct Free','0','20',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 28,'critical','threshold','integer','Critical Swap Pct Free','0','10',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (29, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 35, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (29, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'warn','threshold','float','Warning Filesystem Pct Used','0','75',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'critical','threshold','float','Critical Filesystem Pct Used','0','90',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'fs_0','config','string','Filesystem','1','/dev/hda1',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (30, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (30, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'warn','threshold','integer','Warning Users','0','10',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'critical','threshold','integer','Critical Users','0','50',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (31, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (31, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'warn','threshold','integer','Warning Process Count','0','400',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'critical','threshold','integer','Critical Process Count','0','700',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'critical_time','config','integer','critical_time','0','500',NULL,NULL,2,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'critical_loss','config','integer','critical_loss','0','80',NULL,NULL,3,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'packets','config','integer','packets','0','20',NULL,NULL,4,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'timeout','config','integer','Timeout (seconds)','0','10',NULL,NULL,5,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'sat_0','config','string','sat_0','1','$SAT$',NULL,NULL,6,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,7,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 32,'host_check','config','integer','host_check','0','1',NULL,NULL,8,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 41,'state','config','probestate','Status (OK/WARNING/CRITICAL/UNKNOWN)','1','OK',NULL,NULL,1,'text',10,10,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'r_port_0','config','integer','IMAP Port','1','143',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'expect','config','generic','Expect','1','OK',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'warning','threshold','integer','Warning Latency','0','2',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'critical','threshold','integer','Critical Latency','0','3',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 42,'timeout','config','integer','Timeout (seconds)','1','5',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'ip','config','string','hostaddress','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'proto','config','string','Protocol (TCP/UDP)','1','udp',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'service','config','string','Service Name','1','nfs',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'warning','threshold','integer','Warning Latency','0','2',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 48,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'r_ip_0','config','string','r_ip_0','1','$HOSTADDRESS$',NULL,NULL,120,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'r_port_0','config','integer','HTTPS Port','1','443',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'warning','threshold','integer','Warning Latency','0','3',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'critical','threshold','integer','Critical Latency','0','5',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'timeout','config','integer','Timeout (seconds)','1','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'expect_header','config','string','Expect Header','0','HTTP/1',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'url','config','string','URL Path','0','/',NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'expect_content','config','string','Expect Content','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'useragent','config','string','UserAgent','1','NOCpulse-check_http/1.0',NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'username','config','string','Username','0',NULL,NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 56,'password','config','password','Password','0',NULL,NULL,NULL,70,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 58,'state','config','string','state','1','OK',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 58,'message','config','string','message','0','(ICMP blocked -- host assumed up)',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 60,'warning','threshold','integer','Warning Seconds','0','5',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 60,'critical','threshold','integer','Critical Seconds','0','10',NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 61,'warning','threshold','integer','Warning Count','0',NULL,NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 61,'critical','threshold','integer','Critical Count','0',NULL,NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'ip_0','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,80,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'sid_0','config','string','Oracle SID','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,40,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'warn','threshold','integer','Warning Blocking Sessions','0','10',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'critical','threshold','integer','Critical Blocking Sessions','0','20',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'blocktime','config','integer','Time Blocking (seconds)','1','20',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 85,'port_0','config','integer','Oracle Port','1','1521',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ora_host','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,90,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,80,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'warn','threshold','integer','Warning Active Locks','0','50',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'critical','threshold','integer','Critical Active Locks','0','100',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 86,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ora_host','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,40,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'warnpct','threshold','float','Available Space Percent Used Warn if Above','0','60',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'critpct','threshold','float','Available Space Percent Used Critical if Above','0','90',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ora_host','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,130,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,120,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'owner','config','string','Table Owner','1','%',NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'warn','threshold','integer','Number of Allocated Extents Warn if Above','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'critical','threshold','integer','Number of Allocated Extents Critical if Above','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'warnpct','threshold','float','Percent of Available Extents Warn if Above','0','50',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'critpct','threshold','float','Percent of Available Extents Critical if Above','0','90',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ora_host','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,130,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,120,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'owner','config','string','Index Owner','1','%',NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'warn','threshold','integer','Number of Allocated Extents Warn if Above','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'critical','threshold','integer','Number of Allocated Extents Critical if Above','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'warnpct','threshold','integer','Percent of Available Extents Warn if Above','0','50',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'critpct','threshold','integer','Percent of Available Extents Critical if Above','0','90',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'ip_0','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,100,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,90,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'sid_0','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'warn','threshold','integer','Warning Idle Sessions','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'critical','threshold','integer','Critical Idle Sessions','0','20',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'idletime','config','integer','Time Idle (seconds)','1','36000',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 90,'port_0','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ora_host','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,70,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,60,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 91,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'ip_0','config','string','ora_host','0','$HOSTADDRESS$',NULL,NULL,110,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'ORACLE_HOME','config','string','ORACLE_HOME','0','/opt/oracle',NULL,NULL,100,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'sid_0','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'warn','threshold','integer','Warning Active Sessions','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'critical','threshold','integer','Critical Active Sessions','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'warnpct','threshold','integer','Warning Avail Sessions Used Pct','0','60',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'critpct','threshold','integer','Critical Avail Sessions Used Pct','0','90',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 92,'port_0','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,8,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,9,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'user','config','string','Username','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'pass','config','password','Password','0',NULL,NULL,NULL,2,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'warnabove','threshold','float','Warning Open Tables','0','75',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'criticalabove','threshold','float','Critical Open Tables','0','100',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'warnbelow','threshold','float','Warning Open Tables','0','10',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'criticalbelow','threshold','float','Critical Open Tables','0','1',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'port_0','config','integer','MySQL Port','1','3306',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,8,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,9,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'user','config','string','Username','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'pass','config','password','Password','0',NULL,NULL,NULL,2,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'warnabove','threshold','float','Warning Opened Tables','0','1750',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'criticalabove','threshold','float','Critical Opened Tables','0','2000',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'warnbelow','threshold','float','Warning Opened Tables','0','100',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'criticalbelow','threshold','float','Critical Opened Tables','0','1',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'port_0','config','integer','MySQL Port','1','3306',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,8,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,9,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'user','config','string','Username','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'pass','config','password','Password','0',NULL,NULL,NULL,2,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'warnabove','threshold','float','Warning Threads Running','0',NULL,NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'criticalabove','threshold','float','Critical Threads Running','0',NULL,NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'warnbelow','threshold','float','Warning Threads Running','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'criticalbelow','threshold','float','Critical Threads Running','0',NULL,NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'port_0','config','integer','MySQL Port','1','3306',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'ip_0','config','string','ip_0','1','$HOSTADDRESS$',NULL,NULL,8,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'cust_0','config','string','cust_0','1','$CUST$',NULL,NULL,9,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'asset_0','config','string','asset_0','1','$ASSET$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'user','config','string','Username','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'pass','config','password','Password','0',NULL,NULL,NULL,2,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'warnabove','threshold','float','Warning Query Rate','0','1',NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'criticalabove','threshold','float','Critical Query Rate','0','3',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'warnbelow','threshold','float','Warning Query Rate','0','0.1',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'criticalbelow','threshold','float','Critical Query Rate','0','0.05',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'port_0','config','integer','MySQL Port','1','3306',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'host','config','string','host','1','$HOSTADDRESS$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'user','config','string','Username','1',NULL,NULL,NULL,2,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'pass','config','password','Password','0',NULL,NULL,NULL,3,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'port','config','integer','MySQL Port','0','3306',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'db','config','string','Database','1','mysql',NULL,NULL,5,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'command','config','string','Command','1',NULL,NULL,NULL,30,'text',40,1023,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'ok','config','integer','OK Exit Status','1','0',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'warn','config','integer','Warning Exit Status','1','1',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'critical','config','integer','Critical Exit Status','1','2',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (99, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 80, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (99, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 85, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 99,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,110,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,120,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,130,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (105, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 135, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (105, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 140, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'interface_0','config','string','Interface','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'InTrafficLTwarning','threshold','float','Warning Input Rate','0',NULL,NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'InTrafficLTcritical','threshold','float','Critical Input Rate','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'InTrafficGTwarning','threshold','float','Warning Input Rate','0',NULL,NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'InTrafficGTcritical','threshold','float','Critical Input Rate','0',NULL,NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'OutTrafficLTwarning','threshold','float','Warning Output Rate','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'OutTrafficLTcritical','threshold','float','Critical Output Rate','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'OutTrafficGTwarning','threshold','float','Warning Output Rate','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'OutTrafficGTcritical','threshold','float','Critical Output Rate','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'log','config','string','Log file','1','/var/log/messages',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (106, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 50, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (106, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 55, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'timeout','config','integer','Timeout (seconds)','1','20',0,300,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_bytes_above','threshold','integer','Critical Size','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_bytes_above','threshold','integer','Warning Size','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_bytes_below','threshold','integer','Warning Size','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_bytes_below','threshold','integer','Critical Size','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_byte_rate_above','threshold','float','Critical Output Rate','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_byte_rate_above','threshold','float','Warning Output Rate','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_byte_rate_below','threshold','float','Warning Output Rate','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_byte_rate_below','threshold','float','Critical Output Rate','0',NULL,NULL,NULL,140,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_lines_above','threshold','integer','Critical Lines','0',NULL,NULL,NULL,150,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_lines_above','threshold','integer','Warning Lines','0',NULL,NULL,NULL,160,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_lines_below','threshold','integer','Warning Lines','0',NULL,NULL,NULL,170,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_lines_below','threshold','integer','Critical Lines','0',NULL,NULL,NULL,180,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_line_rate_above','threshold','float','Critical Line Rate','0',NULL,NULL,NULL,190,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_line_rate_above','threshold','float','Warning Line Rate','0',NULL,NULL,NULL,200,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'warn_line_rate_below','threshold','float','Warning Line Rate','0',NULL,NULL,NULL,210,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 106,'critical_line_rate_below','threshold','float','Critical Line Rate','0',NULL,NULL,NULL,220,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'log','config','string','Log file','1','/var/log/messages',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'regex','config','string','Basic regular expression','1',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values (107, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL,60, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (107, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 65, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'timeout','config','integer','Timeout (seconds)','1','45',0,300,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'critical_num_above','threshold','integer','Critical Matches','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values ( 107,'warn_num_above','threshold','integer','Warning Matches','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'warn_num_below','threshold','integer','Warning Matches','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'critical_num_below','threshold','integer','Critical Matches','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'critical_rate_above','threshold','float','Critical Match Rate','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'warn_rate_above','threshold','float','Warning Match Rate','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'warn_rate_below','threshold','float','Warning Match Rate','0',NULL,NULL,NULL,140,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 107,'critical_rate_below','threshold','float','Critical Match Rate','0',NULL,NULL,NULL,150,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,90,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,100,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,75,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'sshport','config','integer','RHNMD Port','1','4545',NULL,NULL,76,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (109, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ora_host','config','string','Oracle Hostname or IP','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,40,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ORACLE_HOME','config','string','ORACLE_HOME','1',NULL,NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'dbname','config','string','Expected DB Name (V$DATABASE.NAME)','1',NULL,NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 109,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,1,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'cust_0','config','generic','cust_0','0','$CUST$',NULL,NULL,2,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'asset_0','config','generic','asset_0','0','$ASSET$',NULL,NULL,3,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'community','config','password','SNMP Community String','1','public',NULL,NULL,4,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'port','config','integer','SNMP Port','1','161',NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'version','config','string','SNMP Version','1','2',NULL,NULL,6,'text',8,20,'1','1','system',sysdate);

insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (117, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (117, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'fs_0','config','string','Filesystem','1','/',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'warn','threshold','float','Warning Inodes Pct Used','0','75',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'critical','threshold','float','Critical Inodes Pct Used','0','90',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (118, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 35, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (118, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 37, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'disk_0','config','string','Disk number or disk name (from iostat)','1','hda',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'warn_read_below','threshold','integer','Warning Read Rate','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'critical_read_below','threshold','integer','Critical Read Rate','0','5',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'warn_read_above','threshold','integer','Warning Read Rate','0','50',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'critical_read_above','threshold','integer','Critical Read Rate','0','75',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'warn_write_below','threshold','integer','Warning Write Rate','0','3',NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'critical_write_below','threshold','integer','Critical Write Rate','0','1',NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'warn_write_above','threshold','integer','Warning Write Rate','0','20',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'critical_write_above','threshold','integer','Critical Write rate','0','30',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 118,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'ip','config','string','hostaddress','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'port','config','integer','Port','1','80',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'urlpath','config','string','Pathname','1','/server-status',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'useragent','config','string','UserAgent','1','NOCpulse-ApacheUptime/1.0',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'username','config','string','Username','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'password','config','password','Password','0',NULL,NULL,NULL,60,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'ip','config','string','hostaddress','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'port','config','integer','Port','1','80',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'urlpath','config','string','Pathname','1','/server-status',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'warnreqs','threshold','integer','Warning Requests','0','5',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'criticalreqs','threshold','integer','Critical Requests','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'warnaccess','threshold','integer','Warning Accesses','0','500',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'criticalaccess','threshold','integer','Critical Accesses','0','5000',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'warntraffic','threshold','integer','Warning Traffic','0','5000',NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'criticaltraffic','threshold','integer','Critical Traffic','0','25000',NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'useragent','config','string','UserAgent','1','NOCpulse-ApacheUptime/1.0',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'username','config','string','Username','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'password','config','password','Password','0',NULL,NULL,NULL,60,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'ip','config','string','hostaddress','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'port','config','integer','Port','1','80',NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'urlpath','config','string','Pathname','1','/server-status',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'warnchild','threshold','integer','Warning Transferred Per Child','0','5',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'criticalchild','threshold','integer','Critical Transferred Per Child','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'warnslot','threshold','integer','Warning Transferred Per Slot','0','5',NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'criticalslot','threshold','integer','Critical Transferred Per Slot','0','10',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'useragent','config','string','UserAgent','1','NOCpulse-ApacheUptime/1.0',NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'username','config','string','Username','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'password','config','password','Password','0',NULL,NULL,NULL,60,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (123, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (123, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'warn','threshold','float','Warning Virtual Mem Pct Free','0','25',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'critical','threshold','float','Critical Virtual Mem Pct Free','0','10',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 123,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'commandName','config','string','Command name','0',NULL,NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'pidFile','config','string','PID file (overrides command name)','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'running','config','integer','running','0','1',NULL,NULL,50,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'groups','config','checkbox','Count process groups','0','1',NULL,NULL,60,'checkbox',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (226, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 80, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (226, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 85, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'timeout','config','integer','Timeout (seconds)','1','15',0,300,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'number_running_min','threshold','integer','Critical Number Running Minimum','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 226,'number_running_max','threshold','integer','Critical Number Running Maximum','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'running','config','integer','running','0','1',NULL,NULL,3,'text',8,20,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'commandName','config','string','Command name','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'pidFile','config','string','PID file (overrides command name)','0',NULL,NULL,NULL,2,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (228, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (228, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'commandName','config','string','Command name','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'pidFile','config','string','PID file (overrides command name)','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'nchildren_warn','threshold','integer','Warning Child Process Groups','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'nchildren_critical','threshold','integer','Critical Child Process Groups','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'nthreads_warn','threshold','integer','Warning Threads','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'nthreads_critical','threshold','integer','Critical Threads','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'vsz_warn','threshold','integer','Warning Virtual Memory Used','0',NULL,NULL,NULL,160,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'vsz_critical','threshold','integer','Critical Virtual Memory Used','0',NULL,NULL,NULL,150,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'commandName','config','string','Command name','0',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'pidFile','config','string','PID file (overrides command name)','0',NULL,NULL,NULL,2,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'nchildren_warn','threshold','integer','Warning Child Process Groups','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'nchildren_critical','threshold','integer','Critical Child Process Groups','0',NULL,NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'nthreads_warn','threshold','integer','Warning Threads','0',NULL,NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'nthreads_critical','threshold','integer','Critical Threads','0',NULL,NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'vsz_warn','threshold','integer','Warning Virtual Memory Used','0',NULL,NULL,NULL,11,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'vsz_critical','threshold','integer','Critical Virtual Memory Used','0',NULL,NULL,NULL,12,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (230, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 31, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (230, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 32, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nblocked_warn','threshold','integer','Warning Blocked Process Count','0',NULL,NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nblocked_critical','threshold','integer','Critical Blocked Process Count','0',NULL,NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nchildren_warn','threshold','integer','Warning Child Process Count','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nchildren_critical','threshold','integer','Critical Child Process Count','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'ndefunct_warn','threshold','integer','Warning Defunct Process Count','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'ndefunct_critical','threshold','integer','Critical Defunct Process Count','0',NULL,NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nstopped_warn','threshold','integer','Warning Stopped Process Count','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nstopped_critical','threshold','integer','Critical Stopped Process Count','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nswapped_warn','threshold','integer','Warning Sleeping Process Count','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'nswapped_critical','threshold','integer','Critical Sleeping Process Count','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nblocked_warn','threshold','integer','Warning Blocked Process Count','0',NULL,NULL,NULL,1,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nblocked_critical','threshold','integer','Critical Blocked Process Count','0',NULL,NULL,NULL,2,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nchildren_warn','threshold','integer','Warning Child Process Count','0',NULL,NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nchildren_critical','threshold','integer','Critical Child Process Count','0',NULL,NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'ndefunct_warn','threshold','integer','Warning Defunct Process Count','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'ndefunct_critical','threshold','integer','Critical Defunct Process Count ','0',NULL,NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nstopped_warn','threshold','integer','Warning Stopped Process Count','0',NULL,NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nstopped_critical','threshold','integer','Critical Stopped Process Count','0',NULL,NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nswapped_warn','threshold','integer','Warning Sleeping Process Count','0',NULL,NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 231,'nswapped_critical','threshold','integer','Critical Sleeping Process Count','0',NULL,NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,30,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (249, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 35, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (249, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 37, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'local_ip','config','string','Local IP address filter pattern list','0',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'local_port','config','integer','Local port number filter','0',NULL,NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'remote_ip','config','string','Remote IP address filter pattern list','0',NULL,NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'remote_port','config','integer','Remote port number filter','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn','threshold','integer','Warning Total Connections','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical','threshold','integer','Critical Total Connections','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn_TIME_WAIT','threshold','integer','Warning TIME_WAIT Connections','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical_TIME_WAIT','threshold','integer','Critical TIME_WAIT Connections','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn_CLOSE_WAIT','threshold','integer','Warning CLOSE_WAIT Connections','0',NULL,NULL,NULL,140,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical_CLOSE_WAIT','threshold','integer','Critical CLOSE_WAIT Connections','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn_FIN_WAIT','threshold','integer','Warning FIN_WAIT Connections','0',NULL,NULL,NULL,160,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical_FIN_WAIT','threshold','integer','Critical FIN_WAIT Connections','0',NULL,NULL,NULL,150,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn_ESTABLISHED','threshold','integer','Warning ESTABLISHED Connections','0',NULL,NULL,NULL,180,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical_ESTABLISHED','threshold','integer','Critical ESTABLISHED Connections','0',NULL,NULL,NULL,170,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'warn_SYN_RCVD','threshold','integer','Warning SYN_RCVD Connections','0',NULL,NULL,NULL,200,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'critical_SYN_RCVD','threshold','integer','Critical SYN_RCVD Connections','0',NULL,NULL,NULL,190,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 249,'timeout','config','integer','Timeout (seconds)','1','15',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 254,'interface_0','config','string','Interface','1','eth0',NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 254,'intrafficGTcritical','threshold','integer','Input Traffic Critical','0',NULL,NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 254,'outtrafficGTcritical','threshold','integer','Output Traffic Critical','0',NULL,NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'shell','config','generic','shell','0','SSHRemoteCommandShell',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'sshhost','config','generic','sshhost','0','$HOSTADDRESS$',NULL,NULL,20,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'command','config','string','Command','1',NULL,NULL,NULL,30,'text',40,1023,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'ok','config','integer','OK Exit Status','1','0',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'warn','config','integer','Warning Exit Status','1','1',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'critical','config','integer','Critical Exit Status','1','2',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'sshuser','config','generic','RHNMD User','1','nocpulse',NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (274, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL,80, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (274, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 85, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 274,'timeout','config','integer','Timeout (seconds)','0','15',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'port','config','integer','SNMP Port','1','161',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'community','config','password','SNMP Community String','1','public',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'server_name','config','string','BEA Server Name','1',NULL,NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'port','config','integer','SNMP Port','1','161',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'community','config','password','SNMP Community String','1','public',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'server_name','config','string','BEA Server Name','1','myserver',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'heapfreeLTwarning','threshold','integer','Warning Heap Free','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'heapfreeLTcritical','threshold','integer','Critical Heap Free','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'heapfreeGTwarning','threshold','integer','Warning Heap Free','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'heapfreeGTcritical','threshold','integer','Critical Heap Free','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,2,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,3,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ora_port','config','integer','Oracle Port','0','1521',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ORACLE_HOME','config','string','ORA_HOME','0','/opt/oracle',NULL,NULL,5,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'ora_host','config','generic','Oracle Host','0','$HOSTADDRESS$',NULL,NULL,6,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ORACLE_HOME','config','string','ORA_HOME','0','/opt/oracle',NULL,NULL,70,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'ora_host','config','generic','Oracle Host','0','$HOSTADDRESS$',NULL,NULL,60,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'warn_max','threshold','integer','Warning Library Cache Miss Ratio','0','2',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'crit_max','threshold','integer','Critical Library Cache Miss Ratio','0','3',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ORACLE_HOME','config','string','ORA_HOME','0','/opt/oracle',NULL,NULL,80,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 280,'ora_host','config','generic','Oracle Host','0','$HOSTADDRESS$',NULL,NULL,90,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,1,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,2,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,3,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'timeout','config','integer','Timeout (seconds)','0','30',NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'req_warn_max','threshold','integer','Warning Redo Log Space Requests','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'req_crit_max','threshold','integer','Critical Redo Log Space Requests','0',NULL,NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'retry_warn_max','threshold','integer','Warning Redo Buffer Allocation Retries','0',NULL,NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'retry_crit_max','threshold','integer','Critical Redo Buffer Allocation Retries','0',NULL,NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ORACLE_HOME','config','string','ORA_HOME','0','/opt/oracle',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 284,'ora_host','config','generic','Oracle Host','0','$HOSTADDRESS$',NULL,NULL,11,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 93,'mysqlpath','config','string','Path to mysqladmin binary','1','/usr/bin/mysqladmin',NULL,NULL,12,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 94,'mysqlpath','config','string','Path to mysqladmin binary','1','/usr/bin/mysqladmin',NULL,NULL,12,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 95,'mysqlpath','config','string','Path to mysqladmin binary','1','/usr/bin/mysqladmin',NULL,NULL,12,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 96,'mysqlpath','config','string','Path to mysqladmin binary','1','/usr/bin/mysqladmin',NULL,NULL,12,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 97,'mysqlpath','config','string','Path to mysql binary','1','/usr/bin/mysql',NULL,NULL,7,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ora_sid','config','string','Oracle SID','1',NULL,NULL,NULL,10,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ora_user','config','string','Oracle Username','1',NULL,NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ora_password','config','password','Oracle Password','1',NULL,NULL,NULL,30,'password',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'timeout','config','integer','Timeout (seconds)','1','30',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'warn_max','threshold','float','Warning Disk Sort Ratio','0','2',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'crit_max','threshold','float','Critical Disk Sort Ratio','0','10',NULL,NULL,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ora_port','config','integer','Oracle Port','1','1521',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ORACLE_HOME','config','string','ORA_HOME','0','/opt/oracle',NULL,NULL,80,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 283,'ora_host','config','generic','Oracle Host','0','$HOSTADDRESS$',NULL,NULL,90,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'port','config','integer','SNMP Port','1','161',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'community','config','password','SNMP Community String','1','public',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'server_name','config','string','BEA Server Name','1','myserver',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'pool_name','config','string','JDBC Pool Name','1','MyJDBC Connection Pool',NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'connectionsGTwarning','threshold','integer','Warning Connections','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'connectionsGTcritical','threshold','integer','Critical Connections','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'connrateGTwarning','threshold','float','Warning Connection Rate','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'connrateGTcritical','threshold','float','Critical Connection Rate','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'waitersGTwarning','threshold','integer','Warning Waiters','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'waitersGTcritical','threshold','integer','Critical Waiters','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'port','config','integer','SNMP Port','1','161',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'community','config','password','SNMP Community String','1','public',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'server_name','config','string','BEA Server Name','1','myserver',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'queue_name','config','string','Queue Name','1','default',NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'idlethreadsGTwarning','threshold','integer','Warning Idle Threads','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'idlethreadsGTcritical','threshold','integer','Critical Idle Threads','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'queuelengthGTwarning','threshold','integer','Warning Queue Length','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'queuelengthGTcritical','threshold','integer','Critical Queue Length','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'requestrateGTwarning','threshold','float','Warning Request Rate','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'requestrateGTcritical','threshold','float','Critical Request Rate','0',NULL,NULL,NULL,120,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'ip','config','string','ip','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'port','config','integer','SNMP Port','1','161',NULL,NULL,30,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'community','config','password','SNMP Community String','1','public',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'server_name','config','string','BEA Server Name','1','myserver',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'servlet_name','config','string','Servlet Name','1',NULL,NULL,NULL,70,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'exectimemvaveGTwarning','threshold','integer','Warning Execution Time Moving Ave','0',NULL,NULL,NULL,110,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'exectimemvaveGTcritical','threshold','integer','Critical Execution Time Moving Ave','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'highexectimeGTwarning','threshold','integer','Warning High Execution Time','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'highexectimeGTcritical','threshold','integer','Critical High Execution Time','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'warn_used','threshold','integer','Warning Space Used','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'critical_used','threshold','integer','Critical Space Used','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'warn_avail','threshold','integer','Warning Space Available','0',NULL,NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'critical_avail','threshold','integer','Critical Space Available','0',NULL,NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'warn_min','threshold','integer','Warning Buffer Cache Hit Ratio','0','80',NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 278,'crit_min','threshold','integer','Critical Buffer Cache Hit Ratio','0','75',NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'warn_min','threshold','integer','Warning Data Dictionary Hit Ratio','0','80',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 279,'crit_min','threshold','integer','Critical Data Dictionary Hit Ratio','0','75',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'cpu_time_rt_warn','threshold','float','Warning CPU Time Rate','0',NULL,NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'cpu_time_rt_critical','threshold','float','Critical CPU Time Rate','0',NULL,NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'physical_mem_used_warn','threshold','integer','Warning Physical Memory Used','0',NULL,NULL,NULL,140,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'physical_mem_used_critical','threshold','integer','Critical Physical Memory Used','0',NULL,NULL,NULL,130,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'cpu_time_rt_warn','threshold','float','Warning CPU Time Rate','0',NULL,NULL,NULL,3,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'cpu_time_rt_critical','threshold','float','Critical CPU Time Rate','0',NULL,NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'physical_mem_used_warn','threshold','integer','Warning Physical Memory Used','0',NULL,NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 229,'physical_mem_used_critical','threshold','integer','Critical Physical Memory Used','0',NULL,NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'number_running_min','threshold','integer','Critical Number Running Minimum','0',NULL,NULL,NULL,4,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'number_running_max','threshold','integer','Critical Number Running Maximum','0',NULL,NULL,NULL,5,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'warn_used','threshold','integer','Warning Space Used','0',NULL,NULL,NULL,6,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'critical_used','threshold','integer','Critical Space Used','0',NULL,NULL,NULL,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'warn_avail','threshold','integer','Warning Space Available','0',NULL,NULL,NULL,8,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 17,'critical_avail','threshold','integer','Critical Space Available','0',NULL,NULL,NULL,9,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 2,'url','config','string','URL (placeholder parameter)','0',NULL,NULL,NULL,1,'text',20,40,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 105,'timeout','config','integer','Timeout (seconds)','1','30',NULL,300,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 254,'timeout','config','integer','Timeout (seconds)','1','30',NULL,300,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 88,'match_name','config','string','Table Name','1','%',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 89,'match_name','config','string','Index Name','1','%',NULL,NULL,60,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 14,'critical_time','threshold','float','Critical Query Time','0',NULL,NULL,NULL,10,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 14,'warning_time','threshold','float','Warning Query Time','0',NULL,NULL,NULL,20,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 27,'timeout','config','integer','Timeout (seconds)','1','15',0,300,35,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 117,'timeout','config','integer','Timeout (seconds)','1','15',0,300,45,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 16,'timeout','config','integer','Timeout (seconds)','1','15',0,300,55,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 29,'timeout','config','integer','Timeout (seconds)','1','15',0,300,45,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 26,'timeout','config','integer','Timeout (seconds)','1','15',0,300,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 228,'timeout','config','integer','Timeout (seconds)','1','15',0,300,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 30,'timeout','config','integer','Timeout (seconds)','1','15',0,300,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 25,'timeout','config','integer','Timeout (seconds)','1','15',0,300,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 31,'timeout','config','integer','Timeout (seconds)','1','15',0,300,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 113,'timeout','config','integer','Timeout (seconds)','1','15',0,300,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 230,'timeout','config','integer','Timeout (seconds)','1','15',0,300,35,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 87,'named_tablespace','config','string','Tablespace Name','1','%',NULL,NULL,55,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 120,'protocol','config','string','Application Protocol','1','http',NULL,NULL,15,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 121,'protocol','config','string','Application Protocol','1','http',NULL,NULL,15,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 122,'protocol','config','string','Application Protocol','1','http',NULL,NULL,15,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'groups','config','checkbox','Count process groups','0','1',NULL,NULL,6,'checkbox',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 227,'timeout','config','integer','Timeout (seconds)','1','15',0,300,7,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'version','config','string','SNMP Version','1','1',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 275,'admin_server','config','string','BEA Domain Admin Server','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'version','config','string','SNMP Version','1','1',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 281,'admin_server','config','string','BEA Domain Admin Server','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'version','config','string','SNMP Version','1','1',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 276,'admin_server','config','string','BEA Domain Admin Server','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'version','config','string','SNMP Version','1','1',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 288,'admin_server','config','string','BEA Domain Admin Server','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'sshhost','config','string','ip address of host to ssh to','1','$HOSTADDRESS$',NULL,NULL,10,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'sshuser','config','string','RHNMD User','1','nocpulse',NULL,NULL,20,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (304, 'sshport', 'config', 'integer', 'RHNMD Port', 1, '4545','1', NULL, 25, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id, param_name, param_type,
data_type_name, description, mandatory, default_value, min_value, max_value,
field_order, field_widget_name, field_visible_length, field_maximum_length,
field_visible, default_value_visible, last_update_user, last_update_date)
    values (304, 'sshbannerignore', 'config', 'integer', 'SSH banner (number of lines)', 0, '',NULL, NULL, 27, 'text', 8, 20, 1, 1, 'system', sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'shell','config','string','shell to use','1','SSHRemoteCommandShell',NULL,NULL,30,'text',40,80,'0','0','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'ip','config','string','Remote IP Address','1',NULL,NULL,NULL,40,'text',40,80,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'packets','config','integer','Packets to send','1','20',NULL,NULL,50,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'timeout','config','integer','Timeout (seconds)','1','15',0,300,60,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'critical_time','threshold','integer','Critical Round-trip Avg','0','15',NULL,NULL,70,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'warn_time','threshold','integer','Warning Round-trip Avg','0','10',NULL,NULL,80,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'critical_loss','threshold','integer','Critical Packet Loss Pct','0','15',NULL,NULL,90,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 304,'warn_loss','threshold','integer','Warning Packet Loss Pct','0','10',NULL,NULL,100,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'version','config','string','SNMP Version','1','1',NULL,NULL,40,'text',8,20,'1','1','system',sysdate);
insert into rhn_command_parameter(command_id,param_name,param_type,
data_type_name,description,mandatory,default_value,min_value,max_value,
field_order,field_widget_name,field_visible_length,field_maximum_length,
field_visible,default_value_visible,last_update_user,last_update_date) 
    values ( 282,'admin_server','config','string','BEA Domain Admin Server','0',NULL,NULL,NULL,50,'text',40,80,'1','1','system',sysdate);

commit;


--Revision 1.5  2004/06/09 19:11:35  system
--bug 124620: pull out all unneeded rhn_command_parameters
--
--Revision 1.4  2004/05/29 21:51:49  pjones
--bugzilla: none -- _data is not for 340, so says kja.
--
--Revision 1.3  2004/05/21 18:44:41  system
--default DNS lookuphost should be www.redhat.com
--
--Revision 1.2  2004/05/04 20:03:38  kja
--Added commits.
--
--Revision 1.1  2004/04/22 20:27:40  kja
--More reference table data.
--
