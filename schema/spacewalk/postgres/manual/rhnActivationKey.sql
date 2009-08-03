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
rhnActivationKey
(
	token		varchar(48) not null constraint rhn_act_key_token_uq unique,
	reg_token_id	numeric not null
			constraint rhn_act_key_reg_tid_fk
				references rhnRegToken(id)
				on delete cascade,
	ks_session_id	numeric	constraint rhn_act_key_ks_sid_fk
				references rhnKickstartSession(id)
				on delete cascade,
	created		timestamp default (current_timestamp) not null,
	modified	timestamp default (current_timestamp) not null
)
  ;

create index rhn_act_key_kssid_rtid_idx
on rhnActivationKey (ks_session_id, reg_token_id)
--        tablespace [[64k_tbs]]
        ;

create index rhn_act_key_rtid_idx 
    on rhnActivationKey (reg_token_id)
--    tablespace [[64k_tbs]]
    ;


