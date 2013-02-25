--
-- Copyright (c) 2013 Red Hat, Inc.
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

create table rhnServerCrash
(
    id              number not null
                    constraint rhn_server_crash_id_pk primary key,
    server_id       number not null
                    constraint rhn_server_crash_sid_fk
                        references rhnServer(id)
                        on delete cascade,
    crash           varchar2(512) not null,
    path            varchar2(1024) not null,
    count           number not null,
    analyzer        varchar2(128),
    architecture    varchar2(16),
    cmdline         varchar2(2048),
    component       varchar2(256),
    executable      varchar2(512),
    kernel          varchar2(128),
    reason          varchar2(512),
    username        varchar2(256),
    package_name_id number
                    constraint rhn_server_crash_pname_id_fk
                        references rhnPackageName(id),
    package_evr_id  number
                    constraint rhn_server_crash_evr_id_fk
                        references rhnPackageEVR(id),
    package_arch_id number
                    constraint rhn_server_crash_arch_id_fk
                        references rhnPackageArch(id),
    storage_path    varchar(1024),
    created         timestamp with local time zone
                        default (current_timestamp) not null,
    modified        timestamp with local time zone
                        default (current_timestamp) not null
)
enable row movement
;

create sequence rhn_server_crash_id_seq start with 1 order;

create unique index rhn_scr_sid_crash
    on rhnServerCrash (server_id, crash)
    tablespace [[8m_tbs]];
