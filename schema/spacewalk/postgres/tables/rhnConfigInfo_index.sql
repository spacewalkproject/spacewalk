-- oracle equivalent source sha1 3330fb01270f88d079ba9e000e3326f249e34d40
--
-- Copyright (c) 2016--2017 Red Hat, Inc.
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
-- FOUR CASES:
-- u|g|f-not  link-null selinux-null
-- u|g|f-not  link-null selinux-not
-- u|g|f null link-not  selinux-not
-- u|g|f null link-not  selinux-null

create unique index rhn_confinfo_ugf_uq
    on rhnConfigInfo (username, groupname, filemode)
 where username is not null and groupname is not null and filemode is not null and selinux_ctx is null and symlink_target_filename_id is null;

create unique index rhn_confinfo_ugf_se_uq
    on rhnConfigInfo (username, groupname, filemode, selinux_ctx)
 where username is not null and groupname is not null and filemode is not null and selinux_ctx is not null and symlink_target_filename_id is null;

create unique index rhn_confinfo_s_uq
    on rhnConfigInfo (symlink_target_filename_id)
 where username is null and groupname is null and filemode is null and selinux_ctx is null and symlink_target_filename_id is not null;

create unique index rhn_confinfo_s_se_uq
    on rhnConfigInfo (symlink_target_filename_id, selinux_ctx)
 where username is null and groupname is null and filemode is null and selinux_ctx is not null and symlink_target_filename_id is not null;
