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

CREATE OR REPLACE
PACKAGE rhn_exception
IS
    CURSOR exception_details(exception_label_in VARCHAR2) IS
        SELECT id, label, message
          FROM rhnException
         WHERE label = exception_label_in;

    PROCEDURE raise_exception(exception_label_in IN VARCHAR2);
    procedure raise_exception_val(
	exception_label_in in varchar2,
        val_in in number
    );
    PROCEDURE lookup_exception(exception_label_in IN VARCHAR2, exception_id_out OUT NUMBER, exception_message_out OUT VARCHAR2);
END rhn_exception;
/
SHOW ERRORS

--
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--
