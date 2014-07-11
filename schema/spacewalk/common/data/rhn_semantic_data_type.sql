--
-- Copyright (c) 2008--2013 Red Hat, Inc.
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

--data for rhn_semantic_data_type

insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'generic','Generic data type','Generic label',NULL,
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'float','Floating-point number',NULL,'npnumber nptype=float',
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'password','Password',NULL,NULL,
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'string','Character string',NULL,NULL,
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'integer','Integer',NULL,'npnumber nptype=int',
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'checkbox','Checkbox',NULL,NULL,
    NULL,'system',current_timestamp);
insert into rhn_semantic_data_type(name,description,label_name,converter_name,
help_file,last_update_user,last_update_date) 
    values ( 'probestate','Probe state',NULL,'probestate',
    NULL,'system',current_timestamp);
commit;

