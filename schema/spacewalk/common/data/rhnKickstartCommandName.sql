--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'deviceprobe', 'Y', 17, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'device', 'Y', 16, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'driverdisk', 'Y', 18, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'nfs', 'Y', 10, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'interactive', 'N', 2, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'harddrive', 'Y', 9, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'upgrade', 'N', 4, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'install', 'N', 3, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'lilocheck', 'N', 5, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'text', 'N', 6, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'network', 'Y', 7, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'url', 'Y', 11, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'lang', 'Y', 12, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'langsupport', 'Y', 13, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'keyboard', 'Y', 14, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'mouse', 'Y', 15, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'zerombr', 'Y', 19, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'clearpart', 'Y', 20, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'bootloader', 'Y', 26, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'timezone', 'Y', 27, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'auth', 'Y', 28, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'reboot', 'N', 31, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'xconfig', 'Y', 32, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'rootpw', 'Y', 29, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'firewall', 'Y', 31, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'skipx', 'N', 32, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'cdrom', 'N', 8, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'selinux', 'Y', 30, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'autostep', 'Y', 1, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'repo', 'Y', 33, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'key', 'Y', 34, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'ignoredisk', 'Y', 35, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'autopart', 'N', 36, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'cmdline', 'N', 37, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'firstboot', 'Y', 38, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'graphical', 'N', 39, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'iscsi', 'Y', 40, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'iscsiname', 'Y', 41, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'logging', 'Y', 42, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'monitor', 'Y', 43, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'multipath', 'Y', 44, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'poweroff', 'N', 45, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'halt', 'N', 46, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'services', 'Y', 47, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'shutdown', 'N', 48, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'user', 'Y', 49, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'vnc', 'Y', 50, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'zfcp', 'Y', 51, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (sequence_nextval('rhn_kscommandname_id_seq'), 'custom', 'Y', 52, 'N');

commit;
