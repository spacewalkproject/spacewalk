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


CREATE TABLE rhn_units
(
    unit_id            VARCHAR2(10) NOT NULL 
                           CONSTRAINT rhn_units_unit_id_pk PRIMARY KEY 
                           USING INDEX TABLESPACE [[64k_tbs]], 
    quantum_id         VARCHAR2(10) NOT NULL, 
    unit_label         VARCHAR2(20), 
    description        VARCHAR2(200), 
    to_base_unit_fn    VARCHAR2(2000), 
    from_base_unit_fn  VARCHAR2(2000), 
    validate_fn        VARCHAR2(2000), 
    last_update_user   VARCHAR2(40), 
    last_update_date   DATE
)
ENABLE ROW MOVEMENT
;

COMMENT ON TABLE rhn_units IS 'units  unit definitions';

CREATE INDEX rhn_units_quantum_id_idx
    ON rhn_units (quantum_id)
    TABLESPACE [[64k_tbs]];

ALTER TABLE rhn_units
    ADD CONSTRAINT rhn_units_qnta0_quantum_id_fk FOREIGN KEY (quantum_id)
    REFERENCES rhn_quanta (quantum_id);

