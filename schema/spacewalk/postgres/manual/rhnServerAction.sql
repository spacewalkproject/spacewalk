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
rhnServerAction
(
        server_id       numeric not null
                        constraint rhn_server_action_sid_fk
                        references rhnServer(id),
        action_id       numeric not null
                        constraint rhn_server_action_aid_fk
                        references rhnAction(id) on delete cascade,
        status          numeric not null
                        constraint rhn_server_action_status_fk
                        references rhnActionStatus(id),
        result_code     numeric,
        result_msg      varchar(1024),
        pickup_time     timestamp,
	remaining_tries	numeric default(5) not null,
        completion_time	timestamp,
        created         timestamp default (current_timestamp) not null,
        modified        timestamp default (current_timestamp) not null,

	constraint rhn_server_action_sid_aid_uq unique ( server_id, action_id )
);

-- you can't create foreign keys to column lists made unique by 
-- "create unique index".  shame on you, oracle.
create index rhn_ser_act_sid_aid_s_idx
        on rhnServerAction(server_id, action_id, status)
--        tablespace [[8m_tbs]]
  ;

create index rhn_ser_act_aid_sid_s_idx
	on rhnServerAction(action_id, server_id, status)
--	tablespace [[8m_tbs]]
;

