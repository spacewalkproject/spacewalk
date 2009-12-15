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

--data for rhn_config_macro

insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CCS_CRYPTKEY', '**CCS_CRYPTKEY**', 'ClusterConfigSvcs encryption key', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CFDBHOST', '%{RHN_SAT_HOSTNAME}', 'Configuration database host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CFDB_NAME', '%{RHN_DB_NAME}', 'Configuration database name', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CFDB_NOTIF_PASSWD', '%{RHN_DB_PASSWD}', 'Configuration database notification user password', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CFDB_PASSWD', '%{RHN_DB_PASSWD}', 'Configuration database password', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CSDBHOST', '%{CFDBHOST}', 'Current state database host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CSDB_NAME', '%{RHN_DB_NAME}', 'Current state database name', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'CSDB_PASSWD', '%{CFDB_PASSWD}', 'Current state database password', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'DOM', '**DOM**', 'Local host domain (e.g. ''redhat.com'')', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'EDOM', '%{DOM}', 'Environment-specific domain (e.g. ''dev.rhn_net'')', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'ENV', 'license', 'Environment (e.g. ''prod'')', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'GRITCH_TARGETCUST', '**GRITCH_TARGETCUST**', 'Administrative destination customer ID', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'GRITCH_TARGETDEST', '%{GRITCH_TARGETCUST}_%{GRITCH_TARGETDESTID}_%{GRITCH_TARGETDESTNAME}', 'Gritch target destination', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'GRITCH_TARGETDESTID', '**GRITCH_TARGETDESTID**', 'Administrative destination recid', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'GRITCH_TARGETDESTNAME', '**GRITCH_TARGETDESTNAME**', 'Administrative destination name', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'INNOVATE_LOGINDIR', 'NULL', 'Innovate login directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'INNOVATE_PASSWD', 'NULL', 'Innovate password', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'IPROTO', 'http', 'Internal protocol (e.g. ''http'')', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'MAIL_MX', '**MAIL_MX**', 'Local mail exchanger', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'MDOM', '**MDOM**', 'Mail domain (e.g. ''redhat.com'' for myemail@redhat.com)', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NOTIFDOWNEMAIL', '%{RHN_ADMIN_EMAIL}', 'Email to notif in case of notif meltdown', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NOTIFHOST', '%{RHN_SAT_HOSTNAME}', 'Notification host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NOTIFURL', '%{IPROTO}://%{NOTIFHOST}/cgi-mod-perl/enqueue.cgi', 'Notification server URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NOTIF_ADMINPORT', '%{RHN_SAT_WEB_PORT}', 'Notification administrative webserver port', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NOTIF_ADMIN_EMAIL', '%{RHN_ADMIN_EMAIL}', 'Notification administrator email', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NPBIN', '/usr/bin', 'Production user bin directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NPETC', '/etc/nocpulse', 'Production user etc directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NPHOME', '/var/lib/%{USER}', 'Production user home directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NPVAR', '/var/log/%{USER}', 'Production user var directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'NPLIB', '/var/lib/%{USER}', 'Production user data directory', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'PORTALURL', '%{XPROTO}://%{RHN_SAT_HOSTNAME}', 'Portal URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_ADMIN_EMAIL', '**RHN_ADMIN_EMAIL**', 'Spacewalk administrator email', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_DB_NAME', '**RHN_DB_NAME**', 'Spacewalk database name ', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_DB_PASSWD', '**RHN_DB_PASSWD**', 'Spacewalk database password', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_DB_TABLE_OWNER', '**RHN_DB_TABLE_OWNER**', 'Spacewalk Database table owner', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_DB_USERNAME', '**RHN_DB_USERNAME**', 'Spacewalk database username', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_SAT_HOSTNAME', '**RHN_SAT_HOSTNAME**', 'Spacewalk hostname (FQDN)', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'RHN_SAT_WEB_PORT', '**RHN_SAT_WEB_PORT**', 'Spacewalk webserver port (80 for http, 443 for https)', '1', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SATCFGHOST', '%{RHN_SAT_HOSTNAME}', 'Satellite configuration host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SATCFGURL', '%{SMONURL}/satconfig', 'Satellite configurator URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SCDBHOST', '%{RHN_SAT_HOSTNAME}', 'State change database host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SCDBURL', '%{IPROTO}://%{SCDBHOST}/scdb', 'State change database URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SCDB_NAME', '%{RHN_DB_NAME}', 'State change database name', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SMONHOST', '%{RHN_SAT_HOSTNAME}', 'SMON host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SMONTEST', '%{RHN_SAT_HOSTNAME}', 'SMON-TEST host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SMONURL', '%{XPROTO}://%{SMONHOST}', 'SMON URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SMON_ADMIN_EMAIL', '%{RHN_ADMIN_EMAIL}', 'Scout administrator email', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SPREADBRIDGE_CLIENTPORT', '443', 'Spread bridge client port', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SSPUT_CRYPTKEY', '**SSPUT_CRYPTKEY**', 'SuperSput crypto key', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'SUPPORTURL', 'https://support.nocpulse.com', 'Support URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'TIMESYNC_MAXDELTA', '60', 'Maximum time skew for auto-adjustment (seconds)', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'TIMESYNC_MINDELTA', '0.3', 'Minimum time skew for auto-adjustment (seconds)', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'TSDBHOST', '%{RHN_SAT_HOSTNAME}', 'Time-series database host', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'TSDBURL', '%{IPROTO}://%{TSDBHOST}/tsdb', 'Time-series database URL', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'USER', 'nocpulse', 'Production user', '0', 'system',sysdate);
insert into rhn_config_macro(name,definition,description,editable,last_update_user,last_update_date)     values ( 'XPROTO', '**XPROTO**', 'External protocol (''http'' or ''https'')', '1', 'system',sysdate);

--
--Revision 1.7  2004/07/15 00:54:11  dfaraldo
--New RHN_CONFIG_MACRO and RHN_CONFIG_PARAMETER static data for the
--combined satellite.
--
