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
-- data for rhnTemplateString

SET SQLBLANKLINES ON
SET SCAN OFF

INSERT INTO rhnTemplateString (id, category_id, label, value, description) 
     VALUES (nextval('rhn_template_str_id_seq'),
             (SELECT TC.id 
                FROM rhnTemplateCategory TC
	       WHERE TC.label = 'email_strings'),
	     'email_footer', '-' || '-the Spacewalk Team', 'Footer for Spacewalk e-mail');

INSERT INTO rhnTemplateString (id, category_id, label, value, description) 
     VALUES (nextval('rhn_template_str_id_seq'),
             (SELECT TC.id 
                FROM rhnTemplateCategory TC
	       WHERE TC.label = 'email_strings'),
	     'email_account_info', '
Account Information:
  Your Spacewalk login:         <login />
  Your Spacewalk email address: <email-address />', 'Account info lines for Spacewalk e-mail');

