--
-- Copyright (c) 2010 Red Hat, Inc.
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


-- RHEL 6  timezones

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Andorra',
	    	'Europe/Andorra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Dubai',
	    	'Asia/Dubai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kabul',
	    	'Asia/Kabul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Antigua',
	    	'America/Antigua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Anguilla',
	    	'America/Anguilla',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Tirane',
	    	'Europe/Tirane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Yerevan',
	    	'Asia/Yerevan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Curacao',
	    	'America/Curacao',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Luanda',
	    	'Africa/Luanda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/McMurdo',
	    	'Antarctica/McMurdo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/South_Pole',
	    	'Antarctica/South_Pole',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Palmer',
	    	'Antarctica/Palmer',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Mawson',
	    	'Antarctica/Mawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Davis',
	    	'Antarctica/Davis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Casey',
	    	'Antarctica/Casey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Vostok',
	    	'Antarctica/Vostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/DumontDUrville',
	    	'Antarctica/DumontDUrville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Antarctica/Syowa',
	    	'Antarctica/Syowa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Buenos_Aires',
	    	'America/Buenos_Aires',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cordoba',
	    	'America/Cordoba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Jujuy',
	    	'America/Jujuy',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Catamarca',
	    	'America/Catamarca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Mendoza',
	    	'America/Mendoza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Pago_Pago',
	    	'Pacific/Pago_Pago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Vienna',
	    	'Europe/Vienna',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Lord_Howe',
	    	'Australia/Lord_Howe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Hobart',
	    	'Australia/Hobart',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Melbourne',
	    	'Australia/Melbourne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Sydney',
	    	'Australia/Sydney',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Broken_Hill',
	    	'Australia/Broken_Hill',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Brisbane',
	    	'Australia/Brisbane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Lindeman',
	    	'Australia/Lindeman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Adelaide',
	    	'Australia/Adelaide',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Darwin',
	    	'Australia/Darwin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Australia/Perth',
	    	'Australia/Perth',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Aruba',
	    	'America/Aruba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Baku',
	    	'Asia/Baku',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Sarajevo',
	    	'Europe/Sarajevo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Barbados',
	    	'America/Barbados',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Dhaka',
	    	'Asia/Dhaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Brussels',
	    	'Europe/Brussels',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Ouagadougou',
	    	'Africa/Ouagadougou',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Sofia',
	    	'Europe/Sofia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Bahrain',
	    	'Asia/Bahrain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Bujumbura',
	    	'Africa/Bujumbura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Porto-Novo',
	    	'Africa/Porto-Novo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Bermuda',
	    	'Atlantic/Bermuda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Brunei',
	    	'Asia/Brunei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/La_Paz',
	    	'America/La_Paz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Noronha',
	    	'America/Noronha',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Belem',
	    	'America/Belem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Fortaleza',
	    	'America/Fortaleza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Recife',
	    	'America/Recife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Araguaina',
	    	'America/Araguaina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Maceio',
	    	'America/Maceio',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Sao_Paulo',
	    	'America/Sao_Paulo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cuiaba',
	    	'America/Cuiaba',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Porto_Velho',
	    	'America/Porto_Velho',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Boa_Vista',
	    	'America/Boa_Vista',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Manaus',
	    	'America/Manaus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Eirunepe',
	    	'America/Eirunepe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Rio_Branco',
	    	'America/Rio_Branco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Nassau',
	    	'America/Nassau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Thimphu',
	    	'Asia/Thimphu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Gaborone',
	    	'Africa/Gaborone',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Minsk',
	    	'Europe/Minsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Belize',
	    	'America/Belize',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/St_Johns',
	    	'America/St_Johns',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Halifax',
	    	'America/Halifax',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Glace_Bay',
	    	'America/Glace_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Goose_Bay',
	    	'America/Goose_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Montreal',
	    	'America/Montreal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Nipigon',
	    	'America/Nipigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Thunder_Bay',
	    	'America/Thunder_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Pangnirtung',
	    	'America/Pangnirtung',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Iqaluit',
	    	'America/Iqaluit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Rankin_Inlet',
	    	'America/Rankin_Inlet',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Winnipeg',
	    	'America/Winnipeg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Rainy_River',
	    	'America/Rainy_River',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cambridge_Bay',
	    	'America/Cambridge_Bay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Regina',
	    	'America/Regina',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Swift_Current',
	    	'America/Swift_Current',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Edmonton',
	    	'America/Edmonton',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Yellowknife',
	    	'America/Yellowknife',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Inuvik',
	    	'America/Inuvik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Dawson_Creek',
	    	'America/Dawson_Creek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Vancouver',
	    	'America/Vancouver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Whitehorse',
	    	'America/Whitehorse',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Dawson',
	    	'America/Dawson',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Cocos',
	    	'Indian/Cocos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Kinshasa',
	    	'Africa/Kinshasa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Lubumbashi',
	    	'Africa/Lubumbashi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Bangui',
	    	'Africa/Bangui',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Brazzaville',
	    	'Africa/Brazzaville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Zurich',
	    	'Europe/Zurich',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Abidjan',
	    	'Africa/Abidjan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Rarotonga',
	    	'Pacific/Rarotonga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Santiago',
	    	'America/Santiago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Easter',
	    	'Pacific/Easter',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Douala',
	    	'Africa/Douala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Shanghai',
	    	'Asia/Shanghai',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Harbin',
	    	'Asia/Harbin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Chongqing',
	    	'Asia/Chongqing',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Urumqi',
	    	'Asia/Urumqi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kashgar',
	    	'Asia/Kashgar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Bogota',
	    	'America/Bogota',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Costa_Rica',
	    	'America/Costa_Rica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Havana',
	    	'America/Havana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Cape_Verde',
	    	'Atlantic/Cape_Verde',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Christmas',
	    	'Indian/Christmas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Nicosia',
	    	'Asia/Nicosia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Prague',
	    	'Europe/Prague',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Berlin',
	    	'Europe/Berlin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Djibouti',
	    	'Africa/Djibouti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Copenhagen',
	    	'Europe/Copenhagen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Dominica',
	    	'America/Dominica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Santo_Domingo',
	    	'America/Santo_Domingo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Algiers',
	    	'Africa/Algiers',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Guayaquil',
	    	'America/Guayaquil',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Galapagos',
	    	'Pacific/Galapagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Tallinn',
	    	'Europe/Tallinn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Cairo',
	    	'Africa/Cairo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/El_Aaiun',
	    	'Africa/El_Aaiun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Asmera',
	    	'Africa/Asmera',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Madrid',
	    	'Europe/Madrid',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Ceuta',
	    	'Africa/Ceuta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Canary',
	    	'Atlantic/Canary',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Addis_Ababa',
	    	'Africa/Addis_Ababa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Helsinki',
	    	'Europe/Helsinki',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Fiji',
	    	'Pacific/Fiji',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Stanley',
	    	'Atlantic/Stanley',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Yap',
	    	'Pacific/Yap',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Truk',
	    	'Pacific/Truk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Ponape',
	    	'Pacific/Ponape',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Kosrae',
	    	'Pacific/Kosrae',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Faeroe',
	    	'Atlantic/Faeroe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Paris',
	    	'Europe/Paris',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Libreville',
	    	'Africa/Libreville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/London',
	    	'Europe/London',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Belfast',
	    	'Europe/Belfast',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Grenada',
	    	'America/Grenada',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Tbilisi',
	    	'Asia/Tbilisi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cayenne',
	    	'America/Cayenne',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Accra',
	    	'Africa/Accra',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Gibraltar',
	    	'Europe/Gibraltar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Godthab',
	    	'America/Godthab',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Danmarkshavn',
	    	'America/Danmarkshavn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Scoresbysund',
	    	'America/Scoresbysund',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Thule',
	    	'America/Thule',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Banjul',
	    	'Africa/Banjul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Conakry',
	    	'Africa/Conakry',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Guadeloupe',
	    	'America/Guadeloupe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Malabo',
	    	'Africa/Malabo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Athens',
	    	'Europe/Athens',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/South_Georgia',
	    	'Atlantic/South_Georgia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Guatemala',
	    	'America/Guatemala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Guam',
	    	'Pacific/Guam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Bissau',
	    	'Africa/Bissau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Guyana',
	    	'America/Guyana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Hong_Kong',
	    	'Asia/Hong_Kong',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Tegucigalpa',
	    	'America/Tegucigalpa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Zagreb',
	    	'Europe/Zagreb',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Port-au-Prince',
	    	'America/Port-au-Prince',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Budapest',
	    	'Europe/Budapest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Jakarta',
	    	'Asia/Jakarta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Pontianak',
	    	'Asia/Pontianak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Makassar',
	    	'Asia/Makassar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Jayapura',
	    	'Asia/Jayapura',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Dublin',
	    	'Europe/Dublin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Jerusalem',
	    	'Asia/Jerusalem',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Calcutta',
	    	'Asia/Calcutta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Chagos',
	    	'Indian/Chagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Baghdad',
	    	'Asia/Baghdad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Tehran',
	    	'Asia/Tehran',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Reykjavik',
	    	'Atlantic/Reykjavik',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Rome',
	    	'Europe/Rome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Jamaica',
	    	'America/Jamaica',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Amman',
	    	'Asia/Amman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Tokyo',
	    	'Asia/Tokyo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Nairobi',
	    	'Africa/Nairobi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Bishkek',
	    	'Asia/Bishkek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Phnom_Penh',
	    	'Asia/Phnom_Penh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Tarawa',
	    	'Pacific/Tarawa',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Enderbury',
	    	'Pacific/Enderbury',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Kiritimati',
	    	'Pacific/Kiritimati',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Comoro',
	    	'Indian/Comoro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/St_Kitts',
	    	'America/St_Kitts',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Pyongyang',
	    	'Asia/Pyongyang',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Seoul',
	    	'Asia/Seoul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kuwait',
	    	'Asia/Kuwait',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cayman',
	    	'America/Cayman',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Almaty',
	    	'Asia/Almaty',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Qyzylorda',
	    	'Asia/Qyzylorda',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Aqtobe',
	    	'Asia/Aqtobe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Aqtau',
	    	'Asia/Aqtau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Oral',
	    	'Asia/Oral',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Vientiane',
	    	'Asia/Vientiane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Beirut',
	    	'Asia/Beirut',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/St_Lucia',
	    	'America/St_Lucia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Vaduz',
	    	'Europe/Vaduz',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Colombo',
	    	'Asia/Colombo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Monrovia',
	    	'Africa/Monrovia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Maseru',
	    	'Africa/Maseru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Vilnius',
	    	'Europe/Vilnius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Luxembourg',
	    	'Europe/Luxembourg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Riga',
	    	'Europe/Riga',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Tripoli',
	    	'Africa/Tripoli',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Casablanca',
	    	'Africa/Casablanca',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Monaco',
	    	'Europe/Monaco',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Chisinau',
	    	'Europe/Chisinau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Antananarivo',
	    	'Indian/Antananarivo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Majuro',
	    	'Pacific/Majuro',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Kwajalein',
	    	'Pacific/Kwajalein',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Skopje',
	    	'Europe/Skopje',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Bamako',
	    	'Africa/Bamako',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Timbuktu',
	    	'Africa/Timbuktu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Rangoon',
	    	'Asia/Rangoon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Ulaanbaatar',
	    	'Asia/Ulaanbaatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Hovd',
	    	'Asia/Hovd',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Choibalsan',
	    	'Asia/Choibalsan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Macau',
	    	'Asia/Macau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Saipan',
	    	'Pacific/Saipan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Martinique',
	    	'America/Martinique',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Nouakchott',
	    	'Africa/Nouakchott',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Montserrat',
	    	'America/Montserrat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Malta',
	    	'Europe/Malta',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Mauritius',
	    	'Indian/Mauritius',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Maldives',
	    	'Indian/Maldives',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Blantyre',
	    	'Africa/Blantyre',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Mexico_City',
	    	'America/Mexico_City',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Cancun',
	    	'America/Cancun',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Merida',
	    	'America/Merida',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Monterrey',
	    	'America/Monterrey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Mazatlan',
	    	'America/Mazatlan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Chihuahua',
	    	'America/Chihuahua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Hermosillo',
	    	'America/Hermosillo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Tijuana',
	    	'America/Tijuana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kuala_Lumpur',
	    	'Asia/Kuala_Lumpur',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kuching',
	    	'Asia/Kuching',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Maputo',
	    	'Africa/Maputo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Windhoek',
	    	'Africa/Windhoek',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Noumea',
	    	'Pacific/Noumea',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Niamey',
	    	'Africa/Niamey',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Norfolk',
	    	'Pacific/Norfolk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Lagos',
	    	'Africa/Lagos',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Managua',
	    	'America/Managua',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Amsterdam',
	    	'Europe/Amsterdam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Oslo',
	    	'Europe/Oslo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Katmandu',
	    	'Asia/Katmandu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Nauru',
	    	'Pacific/Nauru',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Niue',
	    	'Pacific/Niue',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Auckland',
	    	'Pacific/Auckland',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Chatham',
	    	'Pacific/Chatham',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Muscat',
	    	'Asia/Muscat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Panama',
	    	'America/Panama',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Lima',
	    	'America/Lima',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Tahiti',
	    	'Pacific/Tahiti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Marquesas',
	    	'Pacific/Marquesas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Gambier',
	    	'Pacific/Gambier',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Port_Moresby',
	    	'Pacific/Port_Moresby',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Manila',
	    	'Asia/Manila',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Karachi',
	    	'Asia/Karachi',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Warsaw',
	    	'Europe/Warsaw',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Miquelon',
	    	'America/Miquelon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Pitcairn',
	    	'Pacific/Pitcairn',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Puerto_Rico',
	    	'America/Puerto_Rico',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Gaza',
	    	'Asia/Gaza',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Lisbon',
	    	'Europe/Lisbon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Madeira',
	    	'Atlantic/Madeira',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Azores',
	    	'Atlantic/Azores',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Palau',
	    	'Pacific/Palau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Asuncion',
	    	'America/Asuncion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Qatar',
	    	'Asia/Qatar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Reunion',
	    	'Indian/Reunion',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Bucharest',
	    	'Europe/Bucharest',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Kaliningrad',
	    	'Europe/Kaliningrad',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Moscow',
	    	'Europe/Moscow',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Samara',
	    	'Europe/Samara',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Yekaterinburg',
	    	'Asia/Yekaterinburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Omsk',
	    	'Asia/Omsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Novosibirsk',
	    	'Asia/Novosibirsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Krasnoyarsk',
	    	'Asia/Krasnoyarsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Irkutsk',
	    	'Asia/Irkutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Yakutsk',
	    	'Asia/Yakutsk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Vladivostok',
	    	'Asia/Vladivostok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Sakhalin',
	    	'Asia/Sakhalin',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Magadan',
	    	'Asia/Magadan',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Kamchatka',
	    	'Asia/Kamchatka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Anadyr',
	    	'Asia/Anadyr',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Kigali',
	    	'Africa/Kigali',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Riyadh',
	    	'Asia/Riyadh',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Guadalcanal',
	    	'Pacific/Guadalcanal',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Mahe',
	    	'Indian/Mahe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Khartoum',
	    	'Africa/Khartoum',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Stockholm',
	    	'Europe/Stockholm',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Singapore',
	    	'Asia/Singapore',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/St_Helena',
	    	'Atlantic/St_Helena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Ljubljana',
	    	'Europe/Ljubljana',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Arctic/Longyearbyen',
	    	'Arctic/Longyearbyen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Atlantic/Jan_Mayen',
	    	'Atlantic/Jan_Mayen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Bratislava',
	    	'Europe/Bratislava',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Freetown',
	    	'Africa/Freetown',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/San_Marino',
	    	'Europe/San_Marino',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Dakar',
	    	'Africa/Dakar',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Mogadishu',
	    	'Africa/Mogadishu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Paramaribo',
	    	'America/Paramaribo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Sao_Tome',
	    	'Africa/Sao_Tome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/El_Salvador',
	    	'America/El_Salvador',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Damascus',
	    	'Asia/Damascus',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Mbabane',
	    	'Africa/Mbabane',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Grand_Turk',
	    	'America/Grand_Turk',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Ndjamena',
	    	'Africa/Ndjamena',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Kerguelen',
	    	'Indian/Kerguelen',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Lome',
	    	'Africa/Lome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Bangkok',
	    	'Asia/Bangkok',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Dushanbe',
	    	'Asia/Dushanbe',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Fakaofo',
	    	'Pacific/Fakaofo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Ashgabat',
	    	'Asia/Ashgabat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Tunis',
	    	'Africa/Tunis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Tongatapu',
	    	'Pacific/Tongatapu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Dili',
	    	'Asia/Dili',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Istanbul',
	    	'Europe/Istanbul',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Port_of_Spain',
	    	'America/Port_of_Spain',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Funafuti',
	    	'Pacific/Funafuti',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Taipei',
	    	'Asia/Taipei',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Dar_es_Salaam',
	    	'Africa/Dar_es_Salaam',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Kiev',
	    	'Europe/Kiev',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Uzhgorod',
	    	'Europe/Uzhgorod',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Zaporozhye',
	    	'Europe/Zaporozhye',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Simferopol',
	    	'Europe/Simferopol',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Kampala',
	    	'Africa/Kampala',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Johnston',
	    	'Pacific/Johnston',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Midway',
	    	'Pacific/Midway',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Wake',
	    	'Pacific/Wake',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/New_York',
	    	'America/New_York',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Detroit',
	    	'America/Detroit',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Louisville',
	    	'America/Louisville',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Kentucky/Monticello',
	    	'America/Kentucky/Monticello',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Indianapolis',
	    	'America/Indianapolis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Indiana/Marengo',
	    	'America/Indiana/Marengo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Indiana/Knox',
	    	'America/Indiana/Knox',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Indiana/Vevay',
	    	'America/Indiana/Vevay',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Chicago',
	    	'America/Chicago',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Menominee',
	    	'America/Menominee',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/North_Dakota/Center',
	    	'America/North_Dakota/Center',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Denver',
	    	'America/Denver',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Boise',
	    	'America/Boise',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Shiprock',
	    	'America/Shiprock',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Phoenix',
	    	'America/Phoenix',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Los_Angeles',
	    	'America/Los_Angeles',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Anchorage',
	    	'America/Anchorage',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Juneau',
	    	'America/Juneau',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Yakutat',
	    	'America/Yakutat',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Nome',
	    	'America/Nome',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Adak',
	    	'America/Adak',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Honolulu',
	    	'Pacific/Honolulu',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Montevideo',
	    	'America/Montevideo',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Samarkand',
	    	'Asia/Samarkand',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Tashkent',
	    	'Asia/Tashkent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Vatican',
	    	'Europe/Vatican',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/St_Vincent',
	    	'America/St_Vincent',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Caracas',
	    	'America/Caracas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Tortola',
	    	'America/Tortola',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/St_Thomas',
	    	'America/St_Thomas',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Saigon',
	    	'Asia/Saigon',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Efate',
	    	'Pacific/Efate',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Wallis',
	    	'Pacific/Wallis',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Pacific/Apia',
	    	'Pacific/Apia',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Asia/Aden',
	    	'Asia/Aden',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Indian/Mayotte',
	    	'Indian/Mayotte',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Europe/Belgrade',
	    	'Europe/Belgrade',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Johannesburg',
	    	'Africa/Johannesburg',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Lusaka',
	    	'Africa/Lusaka',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'Africa/Harare',
	    	'Africa/Harare',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );

insert into rhnKickstartTimezone (id, label, name, install_type)
        values (rhn_ks_timezone_id_seq.nextval,
	    	'America/Toronto',
	    	'America/Toronto',
    	    	(SELECT IT.id FROM rhnKSInstallType IT WHERE IT.label = 'rhel_6')
        );


