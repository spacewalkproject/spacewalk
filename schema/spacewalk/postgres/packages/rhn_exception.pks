create schema rhn_exception;

-- setup search_path so that these functions are created in appropriate schema.
update pg_settings set setting = 'rhn_exception,' || setting where name = 'search_path';

CREATE OR REPLACE FUNCTION is_org_paid (org_id_in IN NUMERIC)
RETURNS NUMERIC
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
