-- oracle equivalent source sha1 d8788d9699268d9d9abe3ed63664842b656c076c
--
-- Copyright (c) 2012 Red Hat, Inc.
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

CREATE TABLE rhnAbrtInfo
(
    id             NUMERIC NOT NULL
                        CONSTRAINT rhn_abrt_info_pk PRIMARY KEY,
    server_id      NUMERIC NOT NULL
                       CONSTRAINT rhn_abrt_info_srvr_fk
                           REFERENCES rhnServer (id)
                           ON DELETE CASCADE,
    num_crashes    NUMERIC NOT NULL,
    created        TIMESTAMPTZ NOT NULL
)

;

CREATE SEQUENCE rhn_abrt_info_id_seq;
