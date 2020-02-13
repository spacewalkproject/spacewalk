-- oracle equivalent source sha1 ac9f0a409adc03930e428d106f393a8d9dec1eb5
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
-- $Id$
--

ALTER TABLE rhnErrataTmp
 ADD severity_id NUMERIC;

ALTER TABLE rhnErrataTmp
 ADD CONSTRAINT rhn_erratatmp_sevid_fk
 FOREIGN KEY (severity_id) REFERENCES rhnErrataSeverity(id);
