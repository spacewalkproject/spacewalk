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

create sequence rhn_conffile_failure_id_seq;

create table
rhnConfigFileFailure
(
	id			numeric not null
				constraint rhn_conffile_fail_id_pk 
					primary key 
--					using index tablespace [[64k_tbs]]
					,
	label			varchar(64) not null
				constraint rhn_conffile_fail_label_uq unique
--					using index tablespace [[64k_tbs]]
					,
	name			varchar(256) not null
				constraint rhn_conffile_fail_name_uq unique
--					using index tablespace [[64k_tbs]]
					,
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
);

