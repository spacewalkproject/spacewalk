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

alter table web_customer add
        staging_content_enabled CHAR(1)
                    DEFAULT ('N') NOT NULL
                CONSTRAINT web_customer_stage_content_chk
                CHECK (staging_content_enabled in ( 'Y' , 'N' ));

alter table web_customer drop column oracle_customer_id;
alter table web_customer drop column oracle_customer_number;
alter table web_customer drop column customer_type;
alter table web_customer drop column credit_application_completed;

