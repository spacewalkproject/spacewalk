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
rhnActionPackageAnswerfile
(
	action_package_id numeric
			constraint rhn_act_p_af_apid_nn not null
			constraint rhn_act_p_af_apid_fk
				references rhnActionPackage(id)
				on delete cascade,
	answerfile	bytea,
	created		timestamp default(current_timestamp) not null,
	modified	timestamp default(current_timestamp) not null
)
--	tablespace [[blob]]
;

create index rhn_act_p_af_aid_idx
	on rhnActionPackageAnswerfile( action_package_id )
--	tablespace [[2m_tbs]]
--	nologging
;

