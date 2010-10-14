-- oracle equivalent source sha1 a6840b2a9d77d1a0e0a2d92794d5cecb7de9563a
--
-- Copyright (c) 2008--2010 Red Hat, Inc.
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

create schema rhn_exception;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_exception,' || setting where name = 'search_path';

CREATE OR REPLACE FUNCTION lookup_exception(exception_label_in IN VARCHAR, exception_id_out OUT NUMERIC, exception_message_out OUT VARCHAR)
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION raise_exception(exception_label_in IN VARCHAR)
RETURNS VOID
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION raise_exception_val(exception_label_in IN VARCHAR,val_in IN NUMERIC)
RETURNS VOID
AS $$
BEGIN
  RAISE EXCEPTION 'Stub called, must be replaced by .pkb';
END;
$$ LANGUAGE PLPGSQL;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_exception')+1) ) where name = 'search_path';
