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

create table
rhnActionDaemonConfig
(
	action_id		numeric not null
				constraint rhn_actiondc_aid_uq unique
--					using index tablespace [[8m_tbs]]
				constraint rhn_actiondc_aid_fk
					references rhnAction(id)
					on delete cascade,
        interval                numeric not null,
        restart                 char(1) default 'Y' not null
                                constraint rhn_actiondc_rest_ck check 
                                    (restart in ('Y','N')),
	created			timestamp default(current_timestamp) not null,
	modified		timestamp default(current_timestamp) not null
);

