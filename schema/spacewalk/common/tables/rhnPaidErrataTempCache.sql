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


CREATE GLOBAL TEMPORARY TABLE rhnPaidErrataTempCache
(
    errata_id  NUMBER,
    user_id    NUMBER,
    server_id  NUMBER
)
ON COMMIT DELETE ROWS
;

CREATE INDEX rhnpec_u_idx
    ON rhnPaidErrataTempCache (user_id);

