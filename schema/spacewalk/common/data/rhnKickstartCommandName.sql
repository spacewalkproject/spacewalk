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

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'deviceprobe', 'Y', 17, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'device', 'Y', 16, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'driverdisk', 'Y', 18, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'include', 'Y', 23, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'nfs', 'Y', 10, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'interactive', 'N', 2, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'harddrive', 'Y', 9, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'upgrade', 'N', 4, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'install', 'N', 3, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'lilocheck', 'N', 5, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'text', 'N', 6, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'network', 'Y', 7, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'url', 'Y', 11, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'lang', 'Y', 12, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'langsupport', 'Y', 13, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'keyboard', 'Y', 14, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'mouse', 'Y', 15, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'zerombr', 'Y', 19, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'clearpart', 'Y', 20, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'bootloader', 'Y', 26, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'timezone', 'Y', 27, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'auth', 'Y', 28, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'reboot', 'N', 31, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'xconfig', 'Y', 32, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'partitions', 'Y', 21, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'rootpw', 'Y', 29, 'Y');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'firewall', 'Y', 31, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'skipx', 'N', 32, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'volgroups', 'Y', 24, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'logvols', 'Y', 25, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'raids', 'Y', 22, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'cdrom', 'N', 8, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'selinux', 'Y', 30, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'autostep', 'Y', 1, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'repo', 'Y', 33, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'key', 'Y', 34, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'ignoredisk', 'Y', 35, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'autopart', 'N', 36, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'cmdline', 'N', 37, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'firstboot', 'Y', 38, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'graphical', 'N', 39, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'iscsi', 'Y', 40, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'iscsiname', 'Y', 41, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'logging', 'Y', 42, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'monitor', 'Y', 43, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'multipath', 'Y', 44, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'poweroff', 'N', 45, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'halt', 'N', 46, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'services', 'Y', 47, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'shutdown', 'N', 48, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'user', 'Y', 49, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'vnc', 'Y', 50, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'zfcp', 'Y', 51, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'custom', 'Y', 52, 'N');

insert into rhnKickstartCommandName (id, name, uses_arguments, sort_order, required)
values (rhn_kscommandname_id_seq.nextval, 'custom_partition', 'Y', 53, 'N');


commit;
