ALTER TABLE rhnkickstartscript ADD error_on_fail CHAR(1)
    DEFAULT ('N') not NULL CONSTRAINT rhn_ksscript_erroronfail_ck
        CHECK (error_on_fail in ('Y','N'));
