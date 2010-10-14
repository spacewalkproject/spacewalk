-- oracle equivalent source sha1 de1cc9f13819c6084b4d7ac8f769631b7ddd90d2
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

-- create schema rhn_exception;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_exception,' || setting where name = 'search_path';

    CREATE OR REPLACE FUNCTION lookup_exception(exception_label_in IN VARCHAR, exception_id_out OUT NUMERIC, exception_message_out OUT VARCHAR)
    AS
    $$
    DECLARE
         exc RECORD;
    BEGIN

        SELECT id, label, message INTO exc
          FROM rhnException
         WHERE label = exception_label_in;

        IF NOT FOUND
        THEN
            RAISE EXCEPTION 'Unable to lookup exception with label (%)',
                  exception_label_in;
        END IF;

        exception_id_out := exc.id;
        exception_message_out := '(' || exc.label || ') - ' || exc.message;
    END;
$$
LANGUAGE PLPGSQL;


    CREATE OR REPLACE FUNCTION raise_exception(exception_label_in IN VARCHAR) RETURNS VOID
    AS
    $$
    DECLARE
	exc_rec	RECORD;
    BEGIN
        exc_rec := rhn_exception.lookup_exception(exception_label_in);
        
        RAISE EXCEPTION '% : %',
          exc_rec.exception_id_out,
          exc_rec.exception_message_out;
    END;
    $$
    LANGUAGE PLPGSQL;

    create or replace function raise_exception_val(exception_label_in in varchar, val_in in numeric) returns void
    as
    $$
    DECLARE
	exc_rec	RECORD;
    BEGIN
        exc_rec := rhn_exception.lookup_exception(exception_label_in);
        
        RAISE EXCEPTION '% : % (%)',
          exc_rec.exception_id_out,
          exc_rec.exception_message_out,
          val_in;
    end;
    $$
    language plpgsql;


-- restore the original setting
update pg_settings set setting = overlay( setting placing '' from 1 for (length('rhn_exception')+1) ) where name = 'search_path';
