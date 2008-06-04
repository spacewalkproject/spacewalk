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
-- $Id$
--
-- XXX should be dev
-- EXCLUDE: all

CREATE OR REPLACE
PACKAGE rhn_swab
IS
    CURSOR message_cursor(recipient_in VARCHAR2, message_type_id_in NUMBER) IS
    SELECT *
      FROM rhnSwabMessage SM
     WHERE recipient = recipient_in
       AND message_type = message_type_id_in
    ORDER BY priority DESC, created DESC
    FOR UPDATE;    

    FUNCTION insert_message(recipient_in VARCHAR2, message_type_in VARCHAR2, priority_in NUMBER, body_in VARCHAR2) RETURN NUMBER;
    FUNCTION receive_message(recipient_in VARCHAR2, message_type_in VARCHAR2) RETURN VARCHAR2;
END rhn_swab;
/
SHOW ERRORS

-- $Log$
-- Revision 1.2  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
