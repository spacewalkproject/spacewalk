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
-- Timezones can change between RHEL releases, so just to be safe, define them separately
-- RHEL 2.1 timezones

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Andorra',
	    	'Europe/Andorra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dubai',
	    	'Asia/Dubai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kabul',
	    	'Asia/Kabul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Antigua',
	    	'America/Antigua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anguilla',
	    	'America/Anguilla',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tirane',
	    	'Europe/Tirane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yerevan',
	    	'Asia/Yerevan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Curacao',
	    	'America/Curacao',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Luanda',
	    	'Africa/Luanda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/McMurdo',
	    	'Antarctica/McMurdo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/South_Pole',
	    	'Antarctica/South_Pole',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Palmer',
	    	'Antarctica/Palmer',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Mawson',
	    	'Antarctica/Mawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Davis',
	    	'Antarctica/Davis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Casey',
	    	'Antarctica/Casey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Vostok',
	    	'Antarctica/Vostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/DumontDUrville',
	    	'Antarctica/DumontDUrville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Syowa',
	    	'Antarctica/Syowa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Buenos_Aires',
	    	'America/Buenos_Aires',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cordoba',
	    	'America/Cordoba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jujuy',
	    	'America/Jujuy',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Catamarca',
	    	'America/Catamarca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mendoza',
	    	'America/Mendoza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pago_Pago',
	    	'Pacific/Pago_Pago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vienna',
	    	'Europe/Vienna',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lord_Howe',
	    	'Australia/Lord_Howe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Hobart',
	    	'Australia/Hobart',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Melbourne',
	    	'Australia/Melbourne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Sydney',
	    	'Australia/Sydney',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Broken_Hill',
	    	'Australia/Broken_Hill',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Brisbane',
	    	'Australia/Brisbane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lindeman',
	    	'Australia/Lindeman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Adelaide',
	    	'Australia/Adelaide',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Darwin',
	    	'Australia/Darwin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Perth',
	    	'Australia/Perth',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Aruba',
	    	'America/Aruba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baku',
	    	'Asia/Baku',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sarajevo',
	    	'Europe/Sarajevo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Barbados',
	    	'America/Barbados',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dhaka',
	    	'Asia/Dhaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Brussels',
	    	'Europe/Brussels',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ouagadougou',
	    	'Africa/Ouagadougou',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sofia',
	    	'Europe/Sofia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bahrain',
	    	'Asia/Bahrain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bujumbura',
	    	'Africa/Bujumbura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Porto-Novo',
	    	'Africa/Porto-Novo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Bermuda',
	    	'Atlantic/Bermuda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Brunei',
	    	'Asia/Brunei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/La_Paz',
	    	'America/La_Paz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Noronha',
	    	'America/Noronha',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belem',
	    	'America/Belem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Fortaleza',
	    	'America/Fortaleza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Recife',
	    	'America/Recife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Araguaina',
	    	'America/Araguaina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Maceio',
	    	'America/Maceio',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Sao_Paulo',
	    	'America/Sao_Paulo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cuiaba',
	    	'America/Cuiaba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Porto_Velho',
	    	'America/Porto_Velho',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boa_Vista',
	    	'America/Boa_Vista',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Manaus',
	    	'America/Manaus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Eirunepe',
	    	'America/Eirunepe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rio_Branco',
	    	'America/Rio_Branco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nassau',
	    	'America/Nassau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Thimphu',
	    	'Asia/Thimphu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Gaborone',
	    	'Africa/Gaborone',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Minsk',
	    	'Europe/Minsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belize',
	    	'America/Belize',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Johns',
	    	'America/St_Johns',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Halifax',
	    	'America/Halifax',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Glace_Bay',
	    	'America/Glace_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Goose_Bay',
	    	'America/Goose_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montreal',
	    	'America/Montreal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nipigon',
	    	'America/Nipigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thunder_Bay',
	    	'America/Thunder_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Pangnirtung',
	    	'America/Pangnirtung',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Iqaluit',
	    	'America/Iqaluit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rankin_Inlet',
	    	'America/Rankin_Inlet',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Winnipeg',
	    	'America/Winnipeg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rainy_River',
	    	'America/Rainy_River',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cambridge_Bay',
	    	'America/Cambridge_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Regina',
	    	'America/Regina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Swift_Current',
	    	'America/Swift_Current',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Edmonton',
	    	'America/Edmonton',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yellowknife',
	    	'America/Yellowknife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Inuvik',
	    	'America/Inuvik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson_Creek',
	    	'America/Dawson_Creek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Vancouver',
	    	'America/Vancouver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Whitehorse',
	    	'America/Whitehorse',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson',
	    	'America/Dawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Cocos',
	    	'Indian/Cocos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kinshasa',
	    	'Africa/Kinshasa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lubumbashi',
	    	'Africa/Lubumbashi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bangui',
	    	'Africa/Bangui',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Brazzaville',
	    	'Africa/Brazzaville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zurich',
	    	'Europe/Zurich',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Abidjan',
	    	'Africa/Abidjan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Rarotonga',
	    	'Pacific/Rarotonga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santiago',
	    	'America/Santiago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Easter',
	    	'Pacific/Easter',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Douala',
	    	'Africa/Douala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Shanghai',
	    	'Asia/Shanghai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Harbin',
	    	'Asia/Harbin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Chongqing',
	    	'Asia/Chongqing',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Urumqi',
	    	'Asia/Urumqi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kashgar',
	    	'Asia/Kashgar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Bogota',
	    	'America/Bogota',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Costa_Rica',
	    	'America/Costa_Rica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Havana',
	    	'America/Havana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Cape_Verde',
	    	'Atlantic/Cape_Verde',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Christmas',
	    	'Indian/Christmas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Nicosia',
	    	'Asia/Nicosia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Prague',
	    	'Europe/Prague',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Berlin',
	    	'Europe/Berlin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Djibouti',
	    	'Africa/Djibouti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Copenhagen',
	    	'Europe/Copenhagen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dominica',
	    	'America/Dominica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santo_Domingo',
	    	'America/Santo_Domingo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Algiers',
	    	'Africa/Algiers',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guayaquil',
	    	'America/Guayaquil',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Galapagos',
	    	'Pacific/Galapagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tallinn',
	    	'Europe/Tallinn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Cairo',
	    	'Africa/Cairo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/El_Aaiun',
	    	'Africa/El_Aaiun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Asmera',
	    	'Africa/Asmera',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Madrid',
	    	'Europe/Madrid',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ceuta',
	    	'Africa/Ceuta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Canary',
	    	'Atlantic/Canary',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Addis_Ababa',
	    	'Africa/Addis_Ababa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Helsinki',
	    	'Europe/Helsinki',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fiji',
	    	'Pacific/Fiji',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Stanley',
	    	'Atlantic/Stanley',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Yap',
	    	'Pacific/Yap',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Truk',
	    	'Pacific/Truk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Ponape',
	    	'Pacific/Ponape',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kosrae',
	    	'Pacific/Kosrae',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Faeroe',
	    	'Atlantic/Faeroe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Paris',
	    	'Europe/Paris',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Libreville',
	    	'Africa/Libreville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/London',
	    	'Europe/London',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belfast',
	    	'Europe/Belfast',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grenada',
	    	'America/Grenada',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tbilisi',
	    	'Asia/Tbilisi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayenne',
	    	'America/Cayenne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Accra',
	    	'Africa/Accra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Gibraltar',
	    	'Europe/Gibraltar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Godthab',
	    	'America/Godthab',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Danmarkshavn',
	    	'America/Danmarkshavn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Scoresbysund',
	    	'America/Scoresbysund',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thule',
	    	'America/Thule',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Banjul',
	    	'Africa/Banjul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Conakry',
	    	'Africa/Conakry',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guadeloupe',
	    	'America/Guadeloupe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Malabo',
	    	'Africa/Malabo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Athens',
	    	'Europe/Athens',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/South_Georgia',
	    	'Atlantic/South_Georgia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guatemala',
	    	'America/Guatemala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guam',
	    	'Pacific/Guam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bissau',
	    	'Africa/Bissau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guyana',
	    	'America/Guyana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hong_Kong',
	    	'Asia/Hong_Kong',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tegucigalpa',
	    	'America/Tegucigalpa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zagreb',
	    	'Europe/Zagreb',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port-au-Prince',
	    	'America/Port-au-Prince',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Budapest',
	    	'Europe/Budapest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jakarta',
	    	'Asia/Jakarta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pontianak',
	    	'Asia/Pontianak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Makassar',
	    	'Asia/Makassar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jayapura',
	    	'Asia/Jayapura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Dublin',
	    	'Europe/Dublin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jerusalem',
	    	'Asia/Jerusalem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Calcutta',
	    	'Asia/Calcutta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Chagos',
	    	'Indian/Chagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baghdad',
	    	'Asia/Baghdad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tehran',
	    	'Asia/Tehran',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Reykjavik',
	    	'Atlantic/Reykjavik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Rome',
	    	'Europe/Rome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jamaica',
	    	'America/Jamaica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Amman',
	    	'Asia/Amman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tokyo',
	    	'Asia/Tokyo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nairobi',
	    	'Africa/Nairobi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bishkek',
	    	'Asia/Bishkek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Phnom_Penh',
	    	'Asia/Phnom_Penh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tarawa',
	    	'Pacific/Tarawa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Enderbury',
	    	'Pacific/Enderbury',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kiritimati',
	    	'Pacific/Kiritimati',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Comoro',
	    	'Indian/Comoro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Kitts',
	    	'America/St_Kitts',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pyongyang',
	    	'Asia/Pyongyang',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Seoul',
	    	'Asia/Seoul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuwait',
	    	'Asia/Kuwait',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayman',
	    	'America/Cayman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Almaty',
	    	'Asia/Almaty',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qyzylorda',
	    	'Asia/Qyzylorda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtobe',
	    	'Asia/Aqtobe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtau',
	    	'Asia/Aqtau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Oral',
	    	'Asia/Oral',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vientiane',
	    	'Asia/Vientiane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Beirut',
	    	'Asia/Beirut',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Lucia',
	    	'America/St_Lucia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vaduz',
	    	'Europe/Vaduz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Colombo',
	    	'Asia/Colombo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Monrovia',
	    	'Africa/Monrovia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maseru',
	    	'Africa/Maseru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vilnius',
	    	'Europe/Vilnius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Luxembourg',
	    	'Europe/Luxembourg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Riga',
	    	'Europe/Riga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tripoli',
	    	'Africa/Tripoli',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Casablanca',
	    	'Africa/Casablanca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Monaco',
	    	'Europe/Monaco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Chisinau',
	    	'Europe/Chisinau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Antananarivo',
	    	'Indian/Antananarivo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Majuro',
	    	'Pacific/Majuro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kwajalein',
	    	'Pacific/Kwajalein',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Skopje',
	    	'Europe/Skopje',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bamako',
	    	'Africa/Bamako',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Timbuktu',
	    	'Africa/Timbuktu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Rangoon',
	    	'Asia/Rangoon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ulaanbaatar',
	    	'Asia/Ulaanbaatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hovd',
	    	'Asia/Hovd',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Choibalsan',
	    	'Asia/Choibalsan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Macau',
	    	'Asia/Macau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Saipan',
	    	'Pacific/Saipan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Martinique',
	    	'America/Martinique',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nouakchott',
	    	'Africa/Nouakchott',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montserrat',
	    	'America/Montserrat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Malta',
	    	'Europe/Malta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mauritius',
	    	'Indian/Mauritius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Maldives',
	    	'Indian/Maldives',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Blantyre',
	    	'Africa/Blantyre',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mexico_City',
	    	'America/Mexico_City',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cancun',
	    	'America/Cancun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Merida',
	    	'America/Merida',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Monterrey',
	    	'America/Monterrey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mazatlan',
	    	'America/Mazatlan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chihuahua',
	    	'America/Chihuahua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Hermosillo',
	    	'America/Hermosillo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tijuana',
	    	'America/Tijuana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuala_Lumpur',
	    	'Asia/Kuala_Lumpur',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuching',
	    	'Asia/Kuching',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maputo',
	    	'Africa/Maputo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Windhoek',
	    	'Africa/Windhoek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Noumea',
	    	'Pacific/Noumea',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Niamey',
	    	'Africa/Niamey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Norfolk',
	    	'Pacific/Norfolk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lagos',
	    	'Africa/Lagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Managua',
	    	'America/Managua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Amsterdam',
	    	'Europe/Amsterdam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Oslo',
	    	'Europe/Oslo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Katmandu',
	    	'Asia/Katmandu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Nauru',
	    	'Pacific/Nauru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Niue',
	    	'Pacific/Niue',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Auckland',
	    	'Pacific/Auckland',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Chatham',
	    	'Pacific/Chatham',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Muscat',
	    	'Asia/Muscat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Panama',
	    	'America/Panama',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Lima',
	    	'America/Lima',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tahiti',
	    	'Pacific/Tahiti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Marquesas',
	    	'Pacific/Marquesas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Gambier',
	    	'Pacific/Gambier',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Port_Moresby',
	    	'Pacific/Port_Moresby',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Manila',
	    	'Asia/Manila',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Karachi',
	    	'Asia/Karachi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Warsaw',
	    	'Europe/Warsaw',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Miquelon',
	    	'America/Miquelon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pitcairn',
	    	'Pacific/Pitcairn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Puerto_Rico',
	    	'America/Puerto_Rico',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Gaza',
	    	'Asia/Gaza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Lisbon',
	    	'Europe/Lisbon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Madeira',
	    	'Atlantic/Madeira',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Azores',
	    	'Atlantic/Azores',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Palau',
	    	'Pacific/Palau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Asuncion',
	    	'America/Asuncion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qatar',
	    	'Asia/Qatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Reunion',
	    	'Indian/Reunion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bucharest',
	    	'Europe/Bucharest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kaliningrad',
	    	'Europe/Kaliningrad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Moscow',
	    	'Europe/Moscow',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Samara',
	    	'Europe/Samara',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yekaterinburg',
	    	'Asia/Yekaterinburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Omsk',
	    	'Asia/Omsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Novosibirsk',
	    	'Asia/Novosibirsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Krasnoyarsk',
	    	'Asia/Krasnoyarsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Irkutsk',
	    	'Asia/Irkutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yakutsk',
	    	'Asia/Yakutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vladivostok',
	    	'Asia/Vladivostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Sakhalin',
	    	'Asia/Sakhalin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Magadan',
	    	'Asia/Magadan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kamchatka',
	    	'Asia/Kamchatka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Anadyr',
	    	'Asia/Anadyr',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kigali',
	    	'Africa/Kigali',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Riyadh',
	    	'Asia/Riyadh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guadalcanal',
	    	'Pacific/Guadalcanal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mahe',
	    	'Indian/Mahe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Khartoum',
	    	'Africa/Khartoum',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Stockholm',
	    	'Europe/Stockholm',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Singapore',
	    	'Asia/Singapore',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/St_Helena',
	    	'Atlantic/St_Helena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Ljubljana',
	    	'Europe/Ljubljana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Arctic/Longyearbyen',
	    	'Arctic/Longyearbyen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Jan_Mayen',
	    	'Atlantic/Jan_Mayen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bratislava',
	    	'Europe/Bratislava',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Freetown',
	    	'Africa/Freetown',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/San_Marino',
	    	'Europe/San_Marino',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dakar',
	    	'Africa/Dakar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mogadishu',
	    	'Africa/Mogadishu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Paramaribo',
	    	'America/Paramaribo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Sao_Tome',
	    	'Africa/Sao_Tome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/El_Salvador',
	    	'America/El_Salvador',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Damascus',
	    	'Asia/Damascus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mbabane',
	    	'Africa/Mbabane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grand_Turk',
	    	'America/Grand_Turk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ndjamena',
	    	'Africa/Ndjamena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Kerguelen',
	    	'Indian/Kerguelen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lome',
	    	'Africa/Lome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bangkok',
	    	'Asia/Bangkok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dushanbe',
	    	'Asia/Dushanbe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fakaofo',
	    	'Pacific/Fakaofo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ashgabat',
	    	'Asia/Ashgabat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tunis',
	    	'Africa/Tunis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tongatapu',
	    	'Pacific/Tongatapu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dili',
	    	'Asia/Dili',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Istanbul',
	    	'Europe/Istanbul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port_of_Spain',
	    	'America/Port_of_Spain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Funafuti',
	    	'Pacific/Funafuti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Taipei',
	    	'Asia/Taipei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dar_es_Salaam',
	    	'Africa/Dar_es_Salaam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kiev',
	    	'Europe/Kiev',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Uzhgorod',
	    	'Europe/Uzhgorod',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zaporozhye',
	    	'Europe/Zaporozhye',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Simferopol',
	    	'Europe/Simferopol',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kampala',
	    	'Africa/Kampala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Johnston',
	    	'Pacific/Johnston',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Midway',
	    	'Pacific/Midway',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wake',
	    	'Pacific/Wake',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/New_York',
	    	'America/New_York',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Detroit',
	    	'America/Detroit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Louisville',
	    	'America/Louisville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Kentucky/Monticello',
	    	'America/Kentucky/Monticello',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indianapolis',
	    	'America/Indianapolis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Marengo',
	    	'America/Indiana/Marengo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Knox',
	    	'America/Indiana/Knox',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Vevay',
	    	'America/Indiana/Vevay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chicago',
	    	'America/Chicago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Menominee',
	    	'America/Menominee',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/North_Dakota/Center',
	    	'America/North_Dakota/Center',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Denver',
	    	'America/Denver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boise',
	    	'America/Boise',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Shiprock',
	    	'America/Shiprock',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Phoenix',
	    	'America/Phoenix',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Los_Angeles',
	    	'America/Los_Angeles',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anchorage',
	    	'America/Anchorage',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Juneau',
	    	'America/Juneau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yakutat',
	    	'America/Yakutat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nome',
	    	'America/Nome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Adak',
	    	'America/Adak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Honolulu',
	    	'Pacific/Honolulu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montevideo',
	    	'America/Montevideo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Samarkand',
	    	'Asia/Samarkand',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tashkent',
	    	'Asia/Tashkent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vatican',
	    	'Europe/Vatican',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Vincent',
	    	'America/St_Vincent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Caracas',
	    	'America/Caracas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tortola',
	    	'America/Tortola',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Thomas',
	    	'America/St_Thomas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Saigon',
	    	'Asia/Saigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Efate',
	    	'Pacific/Efate',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wallis',
	    	'Pacific/Wallis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Apia',
	    	'Pacific/Apia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aden',
	    	'Asia/Aden',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mayotte',
	    	'Indian/Mayotte',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belgrade',
	    	'Europe/Belgrade',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Johannesburg',
	    	'Africa/Johannesburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lusaka',
	    	'Africa/Lusaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Harare',
	    	'Africa/Harare',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Toronto',
	    	'America/Toronto',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_2.1')
        );

-- RHEL 3 timezones

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Andorra',
	    	'Europe/Andorra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dubai',
	    	'Asia/Dubai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kabul',
	    	'Asia/Kabul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Antigua',
	    	'America/Antigua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anguilla',
	    	'America/Anguilla',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tirane',
	    	'Europe/Tirane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yerevan',
	    	'Asia/Yerevan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Curacao',
	    	'America/Curacao',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Luanda',
	    	'Africa/Luanda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/McMurdo',
	    	'Antarctica/McMurdo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/South_Pole',
	    	'Antarctica/South_Pole',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Palmer',
	    	'Antarctica/Palmer',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Mawson',
	    	'Antarctica/Mawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Davis',
	    	'Antarctica/Davis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Casey',
	    	'Antarctica/Casey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Vostok',
	    	'Antarctica/Vostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/DumontDUrville',
	    	'Antarctica/DumontDUrville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Syowa',
	    	'Antarctica/Syowa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Buenos_Aires',
	    	'America/Buenos_Aires',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cordoba',
	    	'America/Cordoba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jujuy',
	    	'America/Jujuy',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Catamarca',
	    	'America/Catamarca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mendoza',
	    	'America/Mendoza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pago_Pago',
	    	'Pacific/Pago_Pago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vienna',
	    	'Europe/Vienna',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lord_Howe',
	    	'Australia/Lord_Howe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Hobart',
	    	'Australia/Hobart',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Melbourne',
	    	'Australia/Melbourne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Sydney',
	    	'Australia/Sydney',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Broken_Hill',
	    	'Australia/Broken_Hill',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Brisbane',
	    	'Australia/Brisbane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lindeman',
	    	'Australia/Lindeman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Adelaide',
	    	'Australia/Adelaide',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Darwin',
	    	'Australia/Darwin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Perth',
	    	'Australia/Perth',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Aruba',
	    	'America/Aruba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baku',
	    	'Asia/Baku',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sarajevo',
	    	'Europe/Sarajevo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Barbados',
	    	'America/Barbados',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dhaka',
	    	'Asia/Dhaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Brussels',
	    	'Europe/Brussels',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ouagadougou',
	    	'Africa/Ouagadougou',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sofia',
	    	'Europe/Sofia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bahrain',
	    	'Asia/Bahrain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bujumbura',
	    	'Africa/Bujumbura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Porto-Novo',
	    	'Africa/Porto-Novo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Bermuda',
	    	'Atlantic/Bermuda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Brunei',
	    	'Asia/Brunei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/La_Paz',
	    	'America/La_Paz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Noronha',
	    	'America/Noronha',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belem',
	    	'America/Belem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Fortaleza',
	    	'America/Fortaleza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Recife',
	    	'America/Recife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Araguaina',
	    	'America/Araguaina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Maceio',
	    	'America/Maceio',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Sao_Paulo',
	    	'America/Sao_Paulo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cuiaba',
	    	'America/Cuiaba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Porto_Velho',
	    	'America/Porto_Velho',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boa_Vista',
	    	'America/Boa_Vista',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Manaus',
	    	'America/Manaus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Eirunepe',
	    	'America/Eirunepe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rio_Branco',
	    	'America/Rio_Branco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nassau',
	    	'America/Nassau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Thimphu',
	    	'Asia/Thimphu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Gaborone',
	    	'Africa/Gaborone',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Minsk',
	    	'Europe/Minsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belize',
	    	'America/Belize',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Johns',
	    	'America/St_Johns',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Halifax',
	    	'America/Halifax',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Glace_Bay',
	    	'America/Glace_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Goose_Bay',
	    	'America/Goose_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montreal',
	    	'America/Montreal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nipigon',
	    	'America/Nipigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thunder_Bay',
	    	'America/Thunder_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Pangnirtung',
	    	'America/Pangnirtung',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Iqaluit',
	    	'America/Iqaluit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rankin_Inlet',
	    	'America/Rankin_Inlet',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Winnipeg',
	    	'America/Winnipeg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rainy_River',
	    	'America/Rainy_River',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cambridge_Bay',
	    	'America/Cambridge_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Regina',
	    	'America/Regina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Swift_Current',
	    	'America/Swift_Current',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Edmonton',
	    	'America/Edmonton',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yellowknife',
	    	'America/Yellowknife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Inuvik',
	    	'America/Inuvik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson_Creek',
	    	'America/Dawson_Creek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Vancouver',
	    	'America/Vancouver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Whitehorse',
	    	'America/Whitehorse',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson',
	    	'America/Dawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Cocos',
	    	'Indian/Cocos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kinshasa',
	    	'Africa/Kinshasa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lubumbashi',
	    	'Africa/Lubumbashi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bangui',
	    	'Africa/Bangui',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Brazzaville',
	    	'Africa/Brazzaville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zurich',
	    	'Europe/Zurich',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Abidjan',
	    	'Africa/Abidjan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Rarotonga',
	    	'Pacific/Rarotonga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santiago',
	    	'America/Santiago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Easter',
	    	'Pacific/Easter',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Douala',
	    	'Africa/Douala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Shanghai',
	    	'Asia/Shanghai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Harbin',
	    	'Asia/Harbin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Chongqing',
	    	'Asia/Chongqing',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Urumqi',
	    	'Asia/Urumqi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kashgar',
	    	'Asia/Kashgar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Bogota',
	    	'America/Bogota',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Costa_Rica',
	    	'America/Costa_Rica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Havana',
	    	'America/Havana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Cape_Verde',
	    	'Atlantic/Cape_Verde',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Christmas',
	    	'Indian/Christmas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Nicosia',
	    	'Asia/Nicosia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Prague',
	    	'Europe/Prague',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Berlin',
	    	'Europe/Berlin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Djibouti',
	    	'Africa/Djibouti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Copenhagen',
	    	'Europe/Copenhagen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dominica',
	    	'America/Dominica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santo_Domingo',
	    	'America/Santo_Domingo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Algiers',
	    	'Africa/Algiers',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guayaquil',
	    	'America/Guayaquil',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Galapagos',
	    	'Pacific/Galapagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tallinn',
	    	'Europe/Tallinn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Cairo',
	    	'Africa/Cairo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/El_Aaiun',
	    	'Africa/El_Aaiun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Asmera',
	    	'Africa/Asmera',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Madrid',
	    	'Europe/Madrid',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ceuta',
	    	'Africa/Ceuta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Canary',
	    	'Atlantic/Canary',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Addis_Ababa',
	    	'Africa/Addis_Ababa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Helsinki',
	    	'Europe/Helsinki',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fiji',
	    	'Pacific/Fiji',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Stanley',
	    	'Atlantic/Stanley',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Yap',
	    	'Pacific/Yap',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Truk',
	    	'Pacific/Truk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Ponape',
	    	'Pacific/Ponape',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kosrae',
	    	'Pacific/Kosrae',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Faeroe',
	    	'Atlantic/Faeroe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Paris',
	    	'Europe/Paris',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Libreville',
	    	'Africa/Libreville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/London',
	    	'Europe/London',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belfast',
	    	'Europe/Belfast',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grenada',
	    	'America/Grenada',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tbilisi',
	    	'Asia/Tbilisi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayenne',
	    	'America/Cayenne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Accra',
	    	'Africa/Accra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Gibraltar',
	    	'Europe/Gibraltar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Godthab',
	    	'America/Godthab',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Danmarkshavn',
	    	'America/Danmarkshavn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Scoresbysund',
	    	'America/Scoresbysund',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thule',
	    	'America/Thule',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Banjul',
	    	'Africa/Banjul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Conakry',
	    	'Africa/Conakry',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guadeloupe',
	    	'America/Guadeloupe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Malabo',
	    	'Africa/Malabo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Athens',
	    	'Europe/Athens',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/South_Georgia',
	    	'Atlantic/South_Georgia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guatemala',
	    	'America/Guatemala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guam',
	    	'Pacific/Guam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bissau',
	    	'Africa/Bissau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guyana',
	    	'America/Guyana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hong_Kong',
	    	'Asia/Hong_Kong',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tegucigalpa',
	    	'America/Tegucigalpa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zagreb',
	    	'Europe/Zagreb',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port-au-Prince',
	    	'America/Port-au-Prince',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Budapest',
	    	'Europe/Budapest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jakarta',
	    	'Asia/Jakarta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pontianak',
	    	'Asia/Pontianak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Makassar',
	    	'Asia/Makassar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jayapura',
	    	'Asia/Jayapura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Dublin',
	    	'Europe/Dublin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jerusalem',
	    	'Asia/Jerusalem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Calcutta',
	    	'Asia/Calcutta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Chagos',
	    	'Indian/Chagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baghdad',
	    	'Asia/Baghdad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tehran',
	    	'Asia/Tehran',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Reykjavik',
	    	'Atlantic/Reykjavik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Rome',
	    	'Europe/Rome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jamaica',
	    	'America/Jamaica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Amman',
	    	'Asia/Amman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tokyo',
	    	'Asia/Tokyo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nairobi',
	    	'Africa/Nairobi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bishkek',
	    	'Asia/Bishkek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Phnom_Penh',
	    	'Asia/Phnom_Penh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tarawa',
	    	'Pacific/Tarawa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Enderbury',
	    	'Pacific/Enderbury',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kiritimati',
	    	'Pacific/Kiritimati',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Comoro',
	    	'Indian/Comoro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Kitts',
	    	'America/St_Kitts',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pyongyang',
	    	'Asia/Pyongyang',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Seoul',
	    	'Asia/Seoul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuwait',
	    	'Asia/Kuwait',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayman',
	    	'America/Cayman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Almaty',
	    	'Asia/Almaty',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qyzylorda',
	    	'Asia/Qyzylorda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtobe',
	    	'Asia/Aqtobe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtau',
	    	'Asia/Aqtau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Oral',
	    	'Asia/Oral',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vientiane',
	    	'Asia/Vientiane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Beirut',
	    	'Asia/Beirut',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Lucia',
	    	'America/St_Lucia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vaduz',
	    	'Europe/Vaduz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Colombo',
	    	'Asia/Colombo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Monrovia',
	    	'Africa/Monrovia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maseru',
	    	'Africa/Maseru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vilnius',
	    	'Europe/Vilnius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Luxembourg',
	    	'Europe/Luxembourg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Riga',
	    	'Europe/Riga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tripoli',
	    	'Africa/Tripoli',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Casablanca',
	    	'Africa/Casablanca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Monaco',
	    	'Europe/Monaco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Chisinau',
	    	'Europe/Chisinau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Antananarivo',
	    	'Indian/Antananarivo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Majuro',
	    	'Pacific/Majuro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kwajalein',
	    	'Pacific/Kwajalein',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Skopje',
	    	'Europe/Skopje',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bamako',
	    	'Africa/Bamako',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Timbuktu',
	    	'Africa/Timbuktu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Rangoon',
	    	'Asia/Rangoon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ulaanbaatar',
	    	'Asia/Ulaanbaatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hovd',
	    	'Asia/Hovd',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Choibalsan',
	    	'Asia/Choibalsan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Macau',
	    	'Asia/Macau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Saipan',
	    	'Pacific/Saipan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Martinique',
	    	'America/Martinique',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nouakchott',
	    	'Africa/Nouakchott',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montserrat',
	    	'America/Montserrat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Malta',
	    	'Europe/Malta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mauritius',
	    	'Indian/Mauritius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Maldives',
	    	'Indian/Maldives',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Blantyre',
	    	'Africa/Blantyre',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mexico_City',
	    	'America/Mexico_City',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cancun',
	    	'America/Cancun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Merida',
	    	'America/Merida',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Monterrey',
	    	'America/Monterrey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mazatlan',
	    	'America/Mazatlan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chihuahua',
	    	'America/Chihuahua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Hermosillo',
	    	'America/Hermosillo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tijuana',
	    	'America/Tijuana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuala_Lumpur',
	    	'Asia/Kuala_Lumpur',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuching',
	    	'Asia/Kuching',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maputo',
	    	'Africa/Maputo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Windhoek',
	    	'Africa/Windhoek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Noumea',
	    	'Pacific/Noumea',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Niamey',
	    	'Africa/Niamey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Norfolk',
	    	'Pacific/Norfolk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lagos',
	    	'Africa/Lagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Managua',
	    	'America/Managua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Amsterdam',
	    	'Europe/Amsterdam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Oslo',
	    	'Europe/Oslo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Katmandu',
	    	'Asia/Katmandu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Nauru',
	    	'Pacific/Nauru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Niue',
	    	'Pacific/Niue',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Auckland',
	    	'Pacific/Auckland',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Chatham',
	    	'Pacific/Chatham',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Muscat',
	    	'Asia/Muscat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Panama',
	    	'America/Panama',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Lima',
	    	'America/Lima',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tahiti',
	    	'Pacific/Tahiti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Marquesas',
	    	'Pacific/Marquesas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Gambier',
	    	'Pacific/Gambier',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Port_Moresby',
	    	'Pacific/Port_Moresby',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Manila',
	    	'Asia/Manila',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Karachi',
	    	'Asia/Karachi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Warsaw',
	    	'Europe/Warsaw',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Miquelon',
	    	'America/Miquelon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pitcairn',
	    	'Pacific/Pitcairn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Puerto_Rico',
	    	'America/Puerto_Rico',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Gaza',
	    	'Asia/Gaza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Lisbon',
	    	'Europe/Lisbon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Madeira',
	    	'Atlantic/Madeira',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Azores',
	    	'Atlantic/Azores',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Palau',
	    	'Pacific/Palau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Asuncion',
	    	'America/Asuncion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qatar',
	    	'Asia/Qatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Reunion',
	    	'Indian/Reunion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bucharest',
	    	'Europe/Bucharest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kaliningrad',
	    	'Europe/Kaliningrad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Moscow',
	    	'Europe/Moscow',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Samara',
	    	'Europe/Samara',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yekaterinburg',
	    	'Asia/Yekaterinburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Omsk',
	    	'Asia/Omsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Novosibirsk',
	    	'Asia/Novosibirsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Krasnoyarsk',
	    	'Asia/Krasnoyarsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Irkutsk',
	    	'Asia/Irkutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yakutsk',
	    	'Asia/Yakutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vladivostok',
	    	'Asia/Vladivostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Sakhalin',
	    	'Asia/Sakhalin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Magadan',
	    	'Asia/Magadan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kamchatka',
	    	'Asia/Kamchatka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Anadyr',
	    	'Asia/Anadyr',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kigali',
	    	'Africa/Kigali',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Riyadh',
	    	'Asia/Riyadh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guadalcanal',
	    	'Pacific/Guadalcanal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mahe',
	    	'Indian/Mahe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Khartoum',
	    	'Africa/Khartoum',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Stockholm',
	    	'Europe/Stockholm',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Singapore',
	    	'Asia/Singapore',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/St_Helena',
	    	'Atlantic/St_Helena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Ljubljana',
	    	'Europe/Ljubljana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Arctic/Longyearbyen',
	    	'Arctic/Longyearbyen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Jan_Mayen',
	    	'Atlantic/Jan_Mayen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bratislava',
	    	'Europe/Bratislava',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Freetown',
	    	'Africa/Freetown',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/San_Marino',
	    	'Europe/San_Marino',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dakar',
	    	'Africa/Dakar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mogadishu',
	    	'Africa/Mogadishu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Paramaribo',
	    	'America/Paramaribo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Sao_Tome',
	    	'Africa/Sao_Tome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/El_Salvador',
	    	'America/El_Salvador',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Damascus',
	    	'Asia/Damascus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mbabane',
	    	'Africa/Mbabane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grand_Turk',
	    	'America/Grand_Turk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ndjamena',
	    	'Africa/Ndjamena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Kerguelen',
	    	'Indian/Kerguelen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lome',
	    	'Africa/Lome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bangkok',
	    	'Asia/Bangkok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dushanbe',
	    	'Asia/Dushanbe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fakaofo',
	    	'Pacific/Fakaofo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ashgabat',
	    	'Asia/Ashgabat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tunis',
	    	'Africa/Tunis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tongatapu',
	    	'Pacific/Tongatapu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dili',
	    	'Asia/Dili',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Istanbul',
	    	'Europe/Istanbul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port_of_Spain',
	    	'America/Port_of_Spain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Funafuti',
	    	'Pacific/Funafuti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Taipei',
	    	'Asia/Taipei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dar_es_Salaam',
	    	'Africa/Dar_es_Salaam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kiev',
	    	'Europe/Kiev',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Uzhgorod',
	    	'Europe/Uzhgorod',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zaporozhye',
	    	'Europe/Zaporozhye',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Simferopol',
	    	'Europe/Simferopol',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kampala',
	    	'Africa/Kampala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Johnston',
	    	'Pacific/Johnston',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Midway',
	    	'Pacific/Midway',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wake',
	    	'Pacific/Wake',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/New_York',
	    	'America/New_York',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Detroit',
	    	'America/Detroit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Louisville',
	    	'America/Louisville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Kentucky/Monticello',
	    	'America/Kentucky/Monticello',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indianapolis',
	    	'America/Indianapolis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Marengo',
	    	'America/Indiana/Marengo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Knox',
	    	'America/Indiana/Knox',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Vevay',
	    	'America/Indiana/Vevay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chicago',
	    	'America/Chicago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Menominee',
	    	'America/Menominee',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/North_Dakota/Center',
	    	'America/North_Dakota/Center',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Denver',
	    	'America/Denver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boise',
	    	'America/Boise',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Shiprock',
	    	'America/Shiprock',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Phoenix',
	    	'America/Phoenix',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Los_Angeles',
	    	'America/Los_Angeles',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anchorage',
	    	'America/Anchorage',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Juneau',
	    	'America/Juneau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yakutat',
	    	'America/Yakutat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nome',
	    	'America/Nome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Adak',
	    	'America/Adak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Honolulu',
	    	'Pacific/Honolulu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montevideo',
	    	'America/Montevideo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Samarkand',
	    	'Asia/Samarkand',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tashkent',
	    	'Asia/Tashkent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vatican',
	    	'Europe/Vatican',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Vincent',
	    	'America/St_Vincent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Caracas',
	    	'America/Caracas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tortola',
	    	'America/Tortola',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Thomas',
	    	'America/St_Thomas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Saigon',
	    	'Asia/Saigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Efate',
	    	'Pacific/Efate',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wallis',
	    	'Pacific/Wallis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Apia',
	    	'Pacific/Apia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aden',
	    	'Asia/Aden',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mayotte',
	    	'Indian/Mayotte',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belgrade',
	    	'Europe/Belgrade',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Johannesburg',
	    	'Africa/Johannesburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lusaka',
	    	'Africa/Lusaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Harare',
	    	'Africa/Harare',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Toronto',
	    	'America/Toronto',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_3')
        );


-- RHEL 4 timezones

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Andorra',
	    	'Europe/Andorra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dubai',
	    	'Asia/Dubai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kabul',
	    	'Asia/Kabul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Antigua',
	    	'America/Antigua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anguilla',
	    	'America/Anguilla',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tirane',
	    	'Europe/Tirane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yerevan',
	    	'Asia/Yerevan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Curacao',
	    	'America/Curacao',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Luanda',
	    	'Africa/Luanda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/McMurdo',
	    	'Antarctica/McMurdo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/South_Pole',
	    	'Antarctica/South_Pole',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Palmer',
	    	'Antarctica/Palmer',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Mawson',
	    	'Antarctica/Mawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Davis',
	    	'Antarctica/Davis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Casey',
	    	'Antarctica/Casey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Vostok',
	    	'Antarctica/Vostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/DumontDUrville',
	    	'Antarctica/DumontDUrville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Syowa',
	    	'Antarctica/Syowa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Buenos_Aires',
	    	'America/Buenos_Aires',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cordoba',
	    	'America/Cordoba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jujuy',
	    	'America/Jujuy',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Catamarca',
	    	'America/Catamarca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mendoza',
	    	'America/Mendoza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pago_Pago',
	    	'Pacific/Pago_Pago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vienna',
	    	'Europe/Vienna',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lord_Howe',
	    	'Australia/Lord_Howe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Hobart',
	    	'Australia/Hobart',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Melbourne',
	    	'Australia/Melbourne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Sydney',
	    	'Australia/Sydney',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Broken_Hill',
	    	'Australia/Broken_Hill',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Brisbane',
	    	'Australia/Brisbane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lindeman',
	    	'Australia/Lindeman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Adelaide',
	    	'Australia/Adelaide',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Darwin',
	    	'Australia/Darwin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Perth',
	    	'Australia/Perth',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Aruba',
	    	'America/Aruba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baku',
	    	'Asia/Baku',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sarajevo',
	    	'Europe/Sarajevo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Barbados',
	    	'America/Barbados',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dhaka',
	    	'Asia/Dhaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Brussels',
	    	'Europe/Brussels',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ouagadougou',
	    	'Africa/Ouagadougou',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sofia',
	    	'Europe/Sofia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bahrain',
	    	'Asia/Bahrain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bujumbura',
	    	'Africa/Bujumbura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Porto-Novo',
	    	'Africa/Porto-Novo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Bermuda',
	    	'Atlantic/Bermuda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Brunei',
	    	'Asia/Brunei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/La_Paz',
	    	'America/La_Paz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Noronha',
	    	'America/Noronha',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belem',
	    	'America/Belem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Fortaleza',
	    	'America/Fortaleza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Recife',
	    	'America/Recife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Araguaina',
	    	'America/Araguaina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Maceio',
	    	'America/Maceio',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Sao_Paulo',
	    	'America/Sao_Paulo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cuiaba',
	    	'America/Cuiaba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Porto_Velho',
	    	'America/Porto_Velho',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boa_Vista',
	    	'America/Boa_Vista',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Manaus',
	    	'America/Manaus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Eirunepe',
	    	'America/Eirunepe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rio_Branco',
	    	'America/Rio_Branco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nassau',
	    	'America/Nassau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Thimphu',
	    	'Asia/Thimphu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Gaborone',
	    	'Africa/Gaborone',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Minsk',
	    	'Europe/Minsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belize',
	    	'America/Belize',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Johns',
	    	'America/St_Johns',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Halifax',
	    	'America/Halifax',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Glace_Bay',
	    	'America/Glace_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Goose_Bay',
	    	'America/Goose_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montreal',
	    	'America/Montreal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nipigon',
	    	'America/Nipigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thunder_Bay',
	    	'America/Thunder_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Pangnirtung',
	    	'America/Pangnirtung',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Iqaluit',
	    	'America/Iqaluit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rankin_Inlet',
	    	'America/Rankin_Inlet',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Winnipeg',
	    	'America/Winnipeg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rainy_River',
	    	'America/Rainy_River',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cambridge_Bay',
	    	'America/Cambridge_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Regina',
	    	'America/Regina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Swift_Current',
	    	'America/Swift_Current',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Edmonton',
	    	'America/Edmonton',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yellowknife',
	    	'America/Yellowknife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Inuvik',
	    	'America/Inuvik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson_Creek',
	    	'America/Dawson_Creek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Vancouver',
	    	'America/Vancouver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Whitehorse',
	    	'America/Whitehorse',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson',
	    	'America/Dawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Cocos',
	    	'Indian/Cocos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kinshasa',
	    	'Africa/Kinshasa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lubumbashi',
	    	'Africa/Lubumbashi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bangui',
	    	'Africa/Bangui',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Brazzaville',
	    	'Africa/Brazzaville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zurich',
	    	'Europe/Zurich',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Abidjan',
	    	'Africa/Abidjan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Rarotonga',
	    	'Pacific/Rarotonga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santiago',
	    	'America/Santiago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Easter',
	    	'Pacific/Easter',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Douala',
	    	'Africa/Douala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Shanghai',
	    	'Asia/Shanghai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Harbin',
	    	'Asia/Harbin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Chongqing',
	    	'Asia/Chongqing',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Urumqi',
	    	'Asia/Urumqi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kashgar',
	    	'Asia/Kashgar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Bogota',
	    	'America/Bogota',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Costa_Rica',
	    	'America/Costa_Rica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Havana',
	    	'America/Havana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Cape_Verde',
	    	'Atlantic/Cape_Verde',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Christmas',
	    	'Indian/Christmas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Nicosia',
	    	'Asia/Nicosia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Prague',
	    	'Europe/Prague',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Berlin',
	    	'Europe/Berlin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Djibouti',
	    	'Africa/Djibouti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Copenhagen',
	    	'Europe/Copenhagen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dominica',
	    	'America/Dominica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santo_Domingo',
	    	'America/Santo_Domingo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Algiers',
	    	'Africa/Algiers',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guayaquil',
	    	'America/Guayaquil',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Galapagos',
	    	'Pacific/Galapagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tallinn',
	    	'Europe/Tallinn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Cairo',
	    	'Africa/Cairo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/El_Aaiun',
	    	'Africa/El_Aaiun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Asmera',
	    	'Africa/Asmera',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Madrid',
	    	'Europe/Madrid',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ceuta',
	    	'Africa/Ceuta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Canary',
	    	'Atlantic/Canary',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Addis_Ababa',
	    	'Africa/Addis_Ababa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Helsinki',
	    	'Europe/Helsinki',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fiji',
	    	'Pacific/Fiji',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Stanley',
	    	'Atlantic/Stanley',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Yap',
	    	'Pacific/Yap',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Truk',
	    	'Pacific/Truk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Ponape',
	    	'Pacific/Ponape',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kosrae',
	    	'Pacific/Kosrae',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Faeroe',
	    	'Atlantic/Faeroe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Paris',
	    	'Europe/Paris',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Libreville',
	    	'Africa/Libreville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/London',
	    	'Europe/London',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belfast',
	    	'Europe/Belfast',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grenada',
	    	'America/Grenada',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tbilisi',
	    	'Asia/Tbilisi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayenne',
	    	'America/Cayenne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Accra',
	    	'Africa/Accra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Gibraltar',
	    	'Europe/Gibraltar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Godthab',
	    	'America/Godthab',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Danmarkshavn',
	    	'America/Danmarkshavn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Scoresbysund',
	    	'America/Scoresbysund',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thule',
	    	'America/Thule',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Banjul',
	    	'Africa/Banjul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Conakry',
	    	'Africa/Conakry',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guadeloupe',
	    	'America/Guadeloupe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Malabo',
	    	'Africa/Malabo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Athens',
	    	'Europe/Athens',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/South_Georgia',
	    	'Atlantic/South_Georgia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guatemala',
	    	'America/Guatemala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guam',
	    	'Pacific/Guam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bissau',
	    	'Africa/Bissau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guyana',
	    	'America/Guyana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hong_Kong',
	    	'Asia/Hong_Kong',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tegucigalpa',
	    	'America/Tegucigalpa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zagreb',
	    	'Europe/Zagreb',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port-au-Prince',
	    	'America/Port-au-Prince',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Budapest',
	    	'Europe/Budapest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jakarta',
	    	'Asia/Jakarta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pontianak',
	    	'Asia/Pontianak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Makassar',
	    	'Asia/Makassar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jayapura',
	    	'Asia/Jayapura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Dublin',
	    	'Europe/Dublin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jerusalem',
	    	'Asia/Jerusalem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Calcutta',
	    	'Asia/Calcutta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Chagos',
	    	'Indian/Chagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baghdad',
	    	'Asia/Baghdad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tehran',
	    	'Asia/Tehran',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Reykjavik',
	    	'Atlantic/Reykjavik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Rome',
	    	'Europe/Rome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jamaica',
	    	'America/Jamaica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Amman',
	    	'Asia/Amman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tokyo',
	    	'Asia/Tokyo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nairobi',
	    	'Africa/Nairobi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bishkek',
	    	'Asia/Bishkek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Phnom_Penh',
	    	'Asia/Phnom_Penh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tarawa',
	    	'Pacific/Tarawa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Enderbury',
	    	'Pacific/Enderbury',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kiritimati',
	    	'Pacific/Kiritimati',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Comoro',
	    	'Indian/Comoro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Kitts',
	    	'America/St_Kitts',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pyongyang',
	    	'Asia/Pyongyang',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Seoul',
	    	'Asia/Seoul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuwait',
	    	'Asia/Kuwait',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayman',
	    	'America/Cayman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Almaty',
	    	'Asia/Almaty',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qyzylorda',
	    	'Asia/Qyzylorda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtobe',
	    	'Asia/Aqtobe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtau',
	    	'Asia/Aqtau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Oral',
	    	'Asia/Oral',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vientiane',
	    	'Asia/Vientiane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Beirut',
	    	'Asia/Beirut',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Lucia',
	    	'America/St_Lucia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vaduz',
	    	'Europe/Vaduz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Colombo',
	    	'Asia/Colombo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Monrovia',
	    	'Africa/Monrovia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maseru',
	    	'Africa/Maseru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vilnius',
	    	'Europe/Vilnius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Luxembourg',
	    	'Europe/Luxembourg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Riga',
	    	'Europe/Riga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tripoli',
	    	'Africa/Tripoli',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Casablanca',
	    	'Africa/Casablanca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Monaco',
	    	'Europe/Monaco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Chisinau',
	    	'Europe/Chisinau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Antananarivo',
	    	'Indian/Antananarivo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Majuro',
	    	'Pacific/Majuro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kwajalein',
	    	'Pacific/Kwajalein',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Skopje',
	    	'Europe/Skopje',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bamako',
	    	'Africa/Bamako',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Timbuktu',
	    	'Africa/Timbuktu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Rangoon',
	    	'Asia/Rangoon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ulaanbaatar',
	    	'Asia/Ulaanbaatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hovd',
	    	'Asia/Hovd',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Choibalsan',
	    	'Asia/Choibalsan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Macau',
	    	'Asia/Macau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Saipan',
	    	'Pacific/Saipan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Martinique',
	    	'America/Martinique',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nouakchott',
	    	'Africa/Nouakchott',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montserrat',
	    	'America/Montserrat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Malta',
	    	'Europe/Malta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mauritius',
	    	'Indian/Mauritius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Maldives',
	    	'Indian/Maldives',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Blantyre',
	    	'Africa/Blantyre',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mexico_City',
	    	'America/Mexico_City',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cancun',
	    	'America/Cancun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Merida',
	    	'America/Merida',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Monterrey',
	    	'America/Monterrey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mazatlan',
	    	'America/Mazatlan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chihuahua',
	    	'America/Chihuahua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Hermosillo',
	    	'America/Hermosillo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tijuana',
	    	'America/Tijuana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuala_Lumpur',
	    	'Asia/Kuala_Lumpur',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuching',
	    	'Asia/Kuching',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maputo',
	    	'Africa/Maputo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Windhoek',
	    	'Africa/Windhoek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Noumea',
	    	'Pacific/Noumea',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Niamey',
	    	'Africa/Niamey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Norfolk',
	    	'Pacific/Norfolk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lagos',
	    	'Africa/Lagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Managua',
	    	'America/Managua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Amsterdam',
	    	'Europe/Amsterdam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Oslo',
	    	'Europe/Oslo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Katmandu',
	    	'Asia/Katmandu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Nauru',
	    	'Pacific/Nauru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Niue',
	    	'Pacific/Niue',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Auckland',
	    	'Pacific/Auckland',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Chatham',
	    	'Pacific/Chatham',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Muscat',
	    	'Asia/Muscat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Panama',
	    	'America/Panama',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Lima',
	    	'America/Lima',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tahiti',
	    	'Pacific/Tahiti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Marquesas',
	    	'Pacific/Marquesas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Gambier',
	    	'Pacific/Gambier',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Port_Moresby',
	    	'Pacific/Port_Moresby',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Manila',
	    	'Asia/Manila',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Karachi',
	    	'Asia/Karachi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Warsaw',
	    	'Europe/Warsaw',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Miquelon',
	    	'America/Miquelon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pitcairn',
	    	'Pacific/Pitcairn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Puerto_Rico',
	    	'America/Puerto_Rico',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Gaza',
	    	'Asia/Gaza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Lisbon',
	    	'Europe/Lisbon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Madeira',
	    	'Atlantic/Madeira',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Azores',
	    	'Atlantic/Azores',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Palau',
	    	'Pacific/Palau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Asuncion',
	    	'America/Asuncion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qatar',
	    	'Asia/Qatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Reunion',
	    	'Indian/Reunion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bucharest',
	    	'Europe/Bucharest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kaliningrad',
	    	'Europe/Kaliningrad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Moscow',
	    	'Europe/Moscow',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Samara',
	    	'Europe/Samara',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yekaterinburg',
	    	'Asia/Yekaterinburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Omsk',
	    	'Asia/Omsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Novosibirsk',
	    	'Asia/Novosibirsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Krasnoyarsk',
	    	'Asia/Krasnoyarsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Irkutsk',
	    	'Asia/Irkutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yakutsk',
	    	'Asia/Yakutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vladivostok',
	    	'Asia/Vladivostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Sakhalin',
	    	'Asia/Sakhalin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Magadan',
	    	'Asia/Magadan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kamchatka',
	    	'Asia/Kamchatka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Anadyr',
	    	'Asia/Anadyr',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kigali',
	    	'Africa/Kigali',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Riyadh',
	    	'Asia/Riyadh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guadalcanal',
	    	'Pacific/Guadalcanal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mahe',
	    	'Indian/Mahe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Khartoum',
	    	'Africa/Khartoum',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Stockholm',
	    	'Europe/Stockholm',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Singapore',
	    	'Asia/Singapore',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/St_Helena',
	    	'Atlantic/St_Helena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Ljubljana',
	    	'Europe/Ljubljana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Arctic/Longyearbyen',
	    	'Arctic/Longyearbyen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Jan_Mayen',
	    	'Atlantic/Jan_Mayen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bratislava',
	    	'Europe/Bratislava',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Freetown',
	    	'Africa/Freetown',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/San_Marino',
	    	'Europe/San_Marino',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dakar',
	    	'Africa/Dakar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mogadishu',
	    	'Africa/Mogadishu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Paramaribo',
	    	'America/Paramaribo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Sao_Tome',
	    	'Africa/Sao_Tome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/El_Salvador',
	    	'America/El_Salvador',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Damascus',
	    	'Asia/Damascus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mbabane',
	    	'Africa/Mbabane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grand_Turk',
	    	'America/Grand_Turk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ndjamena',
	    	'Africa/Ndjamena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Kerguelen',
	    	'Indian/Kerguelen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lome',
	    	'Africa/Lome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bangkok',
	    	'Asia/Bangkok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dushanbe',
	    	'Asia/Dushanbe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fakaofo',
	    	'Pacific/Fakaofo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ashgabat',
	    	'Asia/Ashgabat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tunis',
	    	'Africa/Tunis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tongatapu',
	    	'Pacific/Tongatapu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dili',
	    	'Asia/Dili',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Istanbul',
	    	'Europe/Istanbul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port_of_Spain',
	    	'America/Port_of_Spain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Funafuti',
	    	'Pacific/Funafuti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Taipei',
	    	'Asia/Taipei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dar_es_Salaam',
	    	'Africa/Dar_es_Salaam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kiev',
	    	'Europe/Kiev',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Uzhgorod',
	    	'Europe/Uzhgorod',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zaporozhye',
	    	'Europe/Zaporozhye',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Simferopol',
	    	'Europe/Simferopol',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kampala',
	    	'Africa/Kampala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Johnston',
	    	'Pacific/Johnston',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Midway',
	    	'Pacific/Midway',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wake',
	    	'Pacific/Wake',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/New_York',
	    	'America/New_York',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Detroit',
	    	'America/Detroit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Louisville',
	    	'America/Louisville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Kentucky/Monticello',
	    	'America/Kentucky/Monticello',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indianapolis',
	    	'America/Indianapolis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Marengo',
	    	'America/Indiana/Marengo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Knox',
	    	'America/Indiana/Knox',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Vevay',
	    	'America/Indiana/Vevay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chicago',
	    	'America/Chicago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Menominee',
	    	'America/Menominee',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/North_Dakota/Center',
	    	'America/North_Dakota/Center',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Denver',
	    	'America/Denver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boise',
	    	'America/Boise',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Shiprock',
	    	'America/Shiprock',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Phoenix',
	    	'America/Phoenix',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Los_Angeles',
	    	'America/Los_Angeles',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anchorage',
	    	'America/Anchorage',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Juneau',
	    	'America/Juneau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yakutat',
	    	'America/Yakutat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nome',
	    	'America/Nome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Adak',
	    	'America/Adak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Honolulu',
	    	'Pacific/Honolulu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montevideo',
	    	'America/Montevideo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Samarkand',
	    	'Asia/Samarkand',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tashkent',
	    	'Asia/Tashkent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vatican',
	    	'Europe/Vatican',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Vincent',
	    	'America/St_Vincent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Caracas',
	    	'America/Caracas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tortola',
	    	'America/Tortola',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Thomas',
	    	'America/St_Thomas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Saigon',
	    	'Asia/Saigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Efate',
	    	'Pacific/Efate',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wallis',
	    	'Pacific/Wallis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Apia',
	    	'Pacific/Apia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aden',
	    	'Asia/Aden',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mayotte',
	    	'Indian/Mayotte',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belgrade',
	    	'Europe/Belgrade',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Johannesburg',
	    	'Africa/Johannesburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lusaka',
	    	'Africa/Lusaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Harare',
	    	'Africa/Harare',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Toronto',
	    	'America/Toronto',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_4')
        );

-- RHEL 5 timezones

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Andorra',
	    	'Europe/Andorra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dubai',
	    	'Asia/Dubai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kabul',
	    	'Asia/Kabul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Antigua',
	    	'America/Antigua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anguilla',
	    	'America/Anguilla',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tirane',
	    	'Europe/Tirane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yerevan',
	    	'Asia/Yerevan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Curacao',
	    	'America/Curacao',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Luanda',
	    	'Africa/Luanda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/McMurdo',
	    	'Antarctica/McMurdo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/South_Pole',
	    	'Antarctica/South_Pole',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Palmer',
	    	'Antarctica/Palmer',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Mawson',
	    	'Antarctica/Mawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Davis',
	    	'Antarctica/Davis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Casey',
	    	'Antarctica/Casey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Vostok',
	    	'Antarctica/Vostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/DumontDUrville',
	    	'Antarctica/DumontDUrville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Antarctica/Syowa',
	    	'Antarctica/Syowa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Buenos_Aires',
	    	'America/Buenos_Aires',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cordoba',
	    	'America/Cordoba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jujuy',
	    	'America/Jujuy',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Catamarca',
	    	'America/Catamarca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mendoza',
	    	'America/Mendoza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pago_Pago',
	    	'Pacific/Pago_Pago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vienna',
	    	'Europe/Vienna',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lord_Howe',
	    	'Australia/Lord_Howe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Hobart',
	    	'Australia/Hobart',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Melbourne',
	    	'Australia/Melbourne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Sydney',
	    	'Australia/Sydney',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Broken_Hill',
	    	'Australia/Broken_Hill',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Brisbane',
	    	'Australia/Brisbane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Lindeman',
	    	'Australia/Lindeman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Adelaide',
	    	'Australia/Adelaide',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Darwin',
	    	'Australia/Darwin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Australia/Perth',
	    	'Australia/Perth',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Aruba',
	    	'America/Aruba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baku',
	    	'Asia/Baku',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sarajevo',
	    	'Europe/Sarajevo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Barbados',
	    	'America/Barbados',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dhaka',
	    	'Asia/Dhaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Brussels',
	    	'Europe/Brussels',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ouagadougou',
	    	'Africa/Ouagadougou',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Sofia',
	    	'Europe/Sofia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bahrain',
	    	'Asia/Bahrain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bujumbura',
	    	'Africa/Bujumbura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Porto-Novo',
	    	'Africa/Porto-Novo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Bermuda',
	    	'Atlantic/Bermuda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Brunei',
	    	'Asia/Brunei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/La_Paz',
	    	'America/La_Paz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Noronha',
	    	'America/Noronha',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belem',
	    	'America/Belem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Fortaleza',
	    	'America/Fortaleza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Recife',
	    	'America/Recife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Araguaina',
	    	'America/Araguaina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Maceio',
	    	'America/Maceio',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Sao_Paulo',
	    	'America/Sao_Paulo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cuiaba',
	    	'America/Cuiaba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Porto_Velho',
	    	'America/Porto_Velho',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boa_Vista',
	    	'America/Boa_Vista',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Manaus',
	    	'America/Manaus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Eirunepe',
	    	'America/Eirunepe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rio_Branco',
	    	'America/Rio_Branco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nassau',
	    	'America/Nassau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Thimphu',
	    	'Asia/Thimphu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Gaborone',
	    	'Africa/Gaborone',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Minsk',
	    	'Europe/Minsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Belize',
	    	'America/Belize',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Johns',
	    	'America/St_Johns',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Halifax',
	    	'America/Halifax',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Glace_Bay',
	    	'America/Glace_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Goose_Bay',
	    	'America/Goose_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montreal',
	    	'America/Montreal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nipigon',
	    	'America/Nipigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thunder_Bay',
	    	'America/Thunder_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Pangnirtung',
	    	'America/Pangnirtung',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Iqaluit',
	    	'America/Iqaluit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rankin_Inlet',
	    	'America/Rankin_Inlet',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Winnipeg',
	    	'America/Winnipeg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Rainy_River',
	    	'America/Rainy_River',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cambridge_Bay',
	    	'America/Cambridge_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Regina',
	    	'America/Regina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Swift_Current',
	    	'America/Swift_Current',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Edmonton',
	    	'America/Edmonton',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yellowknife',
	    	'America/Yellowknife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Inuvik',
	    	'America/Inuvik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson_Creek',
	    	'America/Dawson_Creek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Vancouver',
	    	'America/Vancouver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Whitehorse',
	    	'America/Whitehorse',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dawson',
	    	'America/Dawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Cocos',
	    	'Indian/Cocos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kinshasa',
	    	'Africa/Kinshasa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lubumbashi',
	    	'Africa/Lubumbashi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bangui',
	    	'Africa/Bangui',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Brazzaville',
	    	'Africa/Brazzaville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zurich',
	    	'Europe/Zurich',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Abidjan',
	    	'Africa/Abidjan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Rarotonga',
	    	'Pacific/Rarotonga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santiago',
	    	'America/Santiago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Easter',
	    	'Pacific/Easter',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Douala',
	    	'Africa/Douala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Shanghai',
	    	'Asia/Shanghai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Harbin',
	    	'Asia/Harbin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Chongqing',
	    	'Asia/Chongqing',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Urumqi',
	    	'Asia/Urumqi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kashgar',
	    	'Asia/Kashgar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Bogota',
	    	'America/Bogota',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Costa_Rica',
	    	'America/Costa_Rica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Havana',
	    	'America/Havana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Cape_Verde',
	    	'Atlantic/Cape_Verde',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Christmas',
	    	'Indian/Christmas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Nicosia',
	    	'Asia/Nicosia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Prague',
	    	'Europe/Prague',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Berlin',
	    	'Europe/Berlin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Djibouti',
	    	'Africa/Djibouti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Copenhagen',
	    	'Europe/Copenhagen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Dominica',
	    	'America/Dominica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Santo_Domingo',
	    	'America/Santo_Domingo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Algiers',
	    	'Africa/Algiers',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guayaquil',
	    	'America/Guayaquil',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Galapagos',
	    	'Pacific/Galapagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Tallinn',
	    	'Europe/Tallinn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Cairo',
	    	'Africa/Cairo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/El_Aaiun',
	    	'Africa/El_Aaiun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Asmera',
	    	'Africa/Asmera',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Madrid',
	    	'Europe/Madrid',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ceuta',
	    	'Africa/Ceuta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Canary',
	    	'Atlantic/Canary',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Addis_Ababa',
	    	'Africa/Addis_Ababa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Helsinki',
	    	'Europe/Helsinki',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fiji',
	    	'Pacific/Fiji',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Stanley',
	    	'Atlantic/Stanley',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Yap',
	    	'Pacific/Yap',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Truk',
	    	'Pacific/Truk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Ponape',
	    	'Pacific/Ponape',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kosrae',
	    	'Pacific/Kosrae',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Faeroe',
	    	'Atlantic/Faeroe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Paris',
	    	'Europe/Paris',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Libreville',
	    	'Africa/Libreville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/London',
	    	'Europe/London',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belfast',
	    	'Europe/Belfast',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grenada',
	    	'America/Grenada',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tbilisi',
	    	'Asia/Tbilisi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayenne',
	    	'America/Cayenne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Accra',
	    	'Africa/Accra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Gibraltar',
	    	'Europe/Gibraltar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Godthab',
	    	'America/Godthab',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Danmarkshavn',
	    	'America/Danmarkshavn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Scoresbysund',
	    	'America/Scoresbysund',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Thule',
	    	'America/Thule',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Banjul',
	    	'Africa/Banjul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Conakry',
	    	'Africa/Conakry',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guadeloupe',
	    	'America/Guadeloupe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Malabo',
	    	'Africa/Malabo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Athens',
	    	'Europe/Athens',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/South_Georgia',
	    	'Atlantic/South_Georgia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guatemala',
	    	'America/Guatemala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guam',
	    	'Pacific/Guam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bissau',
	    	'Africa/Bissau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Guyana',
	    	'America/Guyana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hong_Kong',
	    	'Asia/Hong_Kong',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tegucigalpa',
	    	'America/Tegucigalpa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zagreb',
	    	'Europe/Zagreb',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port-au-Prince',
	    	'America/Port-au-Prince',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Budapest',
	    	'Europe/Budapest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jakarta',
	    	'Asia/Jakarta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pontianak',
	    	'Asia/Pontianak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Makassar',
	    	'Asia/Makassar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jayapura',
	    	'Asia/Jayapura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Dublin',
	    	'Europe/Dublin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Jerusalem',
	    	'Asia/Jerusalem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Calcutta',
	    	'Asia/Calcutta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Chagos',
	    	'Indian/Chagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Baghdad',
	    	'Asia/Baghdad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tehran',
	    	'Asia/Tehran',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Reykjavik',
	    	'Atlantic/Reykjavik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Rome',
	    	'Europe/Rome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Jamaica',
	    	'America/Jamaica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Amman',
	    	'Asia/Amman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tokyo',
	    	'Asia/Tokyo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nairobi',
	    	'Africa/Nairobi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bishkek',
	    	'Asia/Bishkek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Phnom_Penh',
	    	'Asia/Phnom_Penh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tarawa',
	    	'Pacific/Tarawa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Enderbury',
	    	'Pacific/Enderbury',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kiritimati',
	    	'Pacific/Kiritimati',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Comoro',
	    	'Indian/Comoro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Kitts',
	    	'America/St_Kitts',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Pyongyang',
	    	'Asia/Pyongyang',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Seoul',
	    	'Asia/Seoul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuwait',
	    	'Asia/Kuwait',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cayman',
	    	'America/Cayman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Almaty',
	    	'Asia/Almaty',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qyzylorda',
	    	'Asia/Qyzylorda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtobe',
	    	'Asia/Aqtobe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aqtau',
	    	'Asia/Aqtau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Oral',
	    	'Asia/Oral',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vientiane',
	    	'Asia/Vientiane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Beirut',
	    	'Asia/Beirut',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Lucia',
	    	'America/St_Lucia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vaduz',
	    	'Europe/Vaduz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Colombo',
	    	'Asia/Colombo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Monrovia',
	    	'Africa/Monrovia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maseru',
	    	'Africa/Maseru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vilnius',
	    	'Europe/Vilnius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Luxembourg',
	    	'Europe/Luxembourg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Riga',
	    	'Europe/Riga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tripoli',
	    	'Africa/Tripoli',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Casablanca',
	    	'Africa/Casablanca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Monaco',
	    	'Europe/Monaco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Chisinau',
	    	'Europe/Chisinau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Antananarivo',
	    	'Indian/Antananarivo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Majuro',
	    	'Pacific/Majuro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Kwajalein',
	    	'Pacific/Kwajalein',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Skopje',
	    	'Europe/Skopje',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Bamako',
	    	'Africa/Bamako',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Timbuktu',
	    	'Africa/Timbuktu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Rangoon',
	    	'Asia/Rangoon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ulaanbaatar',
	    	'Asia/Ulaanbaatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Hovd',
	    	'Asia/Hovd',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Choibalsan',
	    	'Asia/Choibalsan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Macau',
	    	'Asia/Macau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Saipan',
	    	'Pacific/Saipan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Martinique',
	    	'America/Martinique',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Nouakchott',
	    	'Africa/Nouakchott',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montserrat',
	    	'America/Montserrat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Malta',
	    	'Europe/Malta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mauritius',
	    	'Indian/Mauritius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Maldives',
	    	'Indian/Maldives',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Blantyre',
	    	'Africa/Blantyre',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mexico_City',
	    	'America/Mexico_City',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Cancun',
	    	'America/Cancun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Merida',
	    	'America/Merida',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Monterrey',
	    	'America/Monterrey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Mazatlan',
	    	'America/Mazatlan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chihuahua',
	    	'America/Chihuahua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Hermosillo',
	    	'America/Hermosillo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tijuana',
	    	'America/Tijuana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuala_Lumpur',
	    	'Asia/Kuala_Lumpur',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kuching',
	    	'Asia/Kuching',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Maputo',
	    	'Africa/Maputo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Windhoek',
	    	'Africa/Windhoek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Noumea',
	    	'Pacific/Noumea',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Niamey',
	    	'Africa/Niamey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Norfolk',
	    	'Pacific/Norfolk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lagos',
	    	'Africa/Lagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Managua',
	    	'America/Managua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Amsterdam',
	    	'Europe/Amsterdam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Oslo',
	    	'Europe/Oslo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Katmandu',
	    	'Asia/Katmandu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Nauru',
	    	'Pacific/Nauru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Niue',
	    	'Pacific/Niue',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Auckland',
	    	'Pacific/Auckland',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Chatham',
	    	'Pacific/Chatham',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Muscat',
	    	'Asia/Muscat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Panama',
	    	'America/Panama',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Lima',
	    	'America/Lima',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tahiti',
	    	'Pacific/Tahiti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Marquesas',
	    	'Pacific/Marquesas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Gambier',
	    	'Pacific/Gambier',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Port_Moresby',
	    	'Pacific/Port_Moresby',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Manila',
	    	'Asia/Manila',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Karachi',
	    	'Asia/Karachi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Warsaw',
	    	'Europe/Warsaw',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Miquelon',
	    	'America/Miquelon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Pitcairn',
	    	'Pacific/Pitcairn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Puerto_Rico',
	    	'America/Puerto_Rico',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Gaza',
	    	'Asia/Gaza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Lisbon',
	    	'Europe/Lisbon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Madeira',
	    	'Atlantic/Madeira',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Azores',
	    	'Atlantic/Azores',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Palau',
	    	'Pacific/Palau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Asuncion',
	    	'America/Asuncion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Qatar',
	    	'Asia/Qatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Reunion',
	    	'Indian/Reunion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bucharest',
	    	'Europe/Bucharest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kaliningrad',
	    	'Europe/Kaliningrad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Moscow',
	    	'Europe/Moscow',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Samara',
	    	'Europe/Samara',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yekaterinburg',
	    	'Asia/Yekaterinburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Omsk',
	    	'Asia/Omsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Novosibirsk',
	    	'Asia/Novosibirsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Krasnoyarsk',
	    	'Asia/Krasnoyarsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Irkutsk',
	    	'Asia/Irkutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Yakutsk',
	    	'Asia/Yakutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Vladivostok',
	    	'Asia/Vladivostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Sakhalin',
	    	'Asia/Sakhalin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Magadan',
	    	'Asia/Magadan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Kamchatka',
	    	'Asia/Kamchatka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Anadyr',
	    	'Asia/Anadyr',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kigali',
	    	'Africa/Kigali',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Riyadh',
	    	'Asia/Riyadh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Guadalcanal',
	    	'Pacific/Guadalcanal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mahe',
	    	'Indian/Mahe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Khartoum',
	    	'Africa/Khartoum',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Stockholm',
	    	'Europe/Stockholm',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Singapore',
	    	'Asia/Singapore',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/St_Helena',
	    	'Atlantic/St_Helena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Ljubljana',
	    	'Europe/Ljubljana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Arctic/Longyearbyen',
	    	'Arctic/Longyearbyen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Atlantic/Jan_Mayen',
	    	'Atlantic/Jan_Mayen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Bratislava',
	    	'Europe/Bratislava',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Freetown',
	    	'Africa/Freetown',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/San_Marino',
	    	'Europe/San_Marino',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dakar',
	    	'Africa/Dakar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mogadishu',
	    	'Africa/Mogadishu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Paramaribo',
	    	'America/Paramaribo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Sao_Tome',
	    	'Africa/Sao_Tome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/El_Salvador',
	    	'America/El_Salvador',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Damascus',
	    	'Asia/Damascus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Mbabane',
	    	'Africa/Mbabane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Grand_Turk',
	    	'America/Grand_Turk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Ndjamena',
	    	'Africa/Ndjamena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Kerguelen',
	    	'Indian/Kerguelen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lome',
	    	'Africa/Lome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Bangkok',
	    	'Asia/Bangkok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dushanbe',
	    	'Asia/Dushanbe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Fakaofo',
	    	'Pacific/Fakaofo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Ashgabat',
	    	'Asia/Ashgabat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Tunis',
	    	'Africa/Tunis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Tongatapu',
	    	'Pacific/Tongatapu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Dili',
	    	'Asia/Dili',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Istanbul',
	    	'Europe/Istanbul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Port_of_Spain',
	    	'America/Port_of_Spain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Funafuti',
	    	'Pacific/Funafuti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Taipei',
	    	'Asia/Taipei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Dar_es_Salaam',
	    	'Africa/Dar_es_Salaam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Kiev',
	    	'Europe/Kiev',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Uzhgorod',
	    	'Europe/Uzhgorod',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Zaporozhye',
	    	'Europe/Zaporozhye',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Simferopol',
	    	'Europe/Simferopol',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Kampala',
	    	'Africa/Kampala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Johnston',
	    	'Pacific/Johnston',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Midway',
	    	'Pacific/Midway',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wake',
	    	'Pacific/Wake',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/New_York',
	    	'America/New_York',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Detroit',
	    	'America/Detroit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Louisville',
	    	'America/Louisville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Kentucky/Monticello',
	    	'America/Kentucky/Monticello',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indianapolis',
	    	'America/Indianapolis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Marengo',
	    	'America/Indiana/Marengo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Knox',
	    	'America/Indiana/Knox',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Indiana/Vevay',
	    	'America/Indiana/Vevay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Chicago',
	    	'America/Chicago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Menominee',
	    	'America/Menominee',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/North_Dakota/Center',
	    	'America/North_Dakota/Center',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Denver',
	    	'America/Denver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Boise',
	    	'America/Boise',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Shiprock',
	    	'America/Shiprock',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Phoenix',
	    	'America/Phoenix',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Los_Angeles',
	    	'America/Los_Angeles',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Anchorage',
	    	'America/Anchorage',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Juneau',
	    	'America/Juneau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Yakutat',
	    	'America/Yakutat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Nome',
	    	'America/Nome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Adak',
	    	'America/Adak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Honolulu',
	    	'Pacific/Honolulu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Montevideo',
	    	'America/Montevideo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Samarkand',
	    	'Asia/Samarkand',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Tashkent',
	    	'Asia/Tashkent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Vatican',
	    	'Europe/Vatican',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Vincent',
	    	'America/St_Vincent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Caracas',
	    	'America/Caracas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Tortola',
	    	'America/Tortola',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/St_Thomas',
	    	'America/St_Thomas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Saigon',
	    	'Asia/Saigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Efate',
	    	'Pacific/Efate',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Wallis',
	    	'Pacific/Wallis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Pacific/Apia',
	    	'Pacific/Apia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Asia/Aden',
	    	'Asia/Aden',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Indian/Mayotte',
	    	'Indian/Mayotte',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Europe/Belgrade',
	    	'Europe/Belgrade',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Johannesburg',
	    	'Africa/Johannesburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Lusaka',
	    	'Africa/Lusaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'Africa/Harare',
	    	'Africa/Harare',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (nextval('rhn_ks_timezone_id_seq'),
	    	'America/Toronto',
	    	'America/Toronto',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_5')
        );


commit;
