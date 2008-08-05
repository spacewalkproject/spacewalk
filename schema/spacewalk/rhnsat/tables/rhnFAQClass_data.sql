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
-- data for rhnFAQClass
--

INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
1, 'General', 'general', 100); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
2, 'Account Management', 'account_management', 120); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
3, 'Getting Started', 'getting_started', 140); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
4, 'Service Levels', 'service_levels', 160); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
5, 'Using Spacewalk', 'using_rhn', 180); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
6, 'Technical Questions', 'technical_questions', 200); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
7, 'Management Service', 'enterprise_service', 220); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
8, 'Privacy/Legal', 'legal', 240); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
9, 'Policies', 'policy', 260); 
INSERT INTO RHNFAQCLASS ( ID, NAME, LABEL, ORDERING ) VALUES ( 
11, 'Definitions', 'definitions', 270); 
COMMIT;

COMMIT;
