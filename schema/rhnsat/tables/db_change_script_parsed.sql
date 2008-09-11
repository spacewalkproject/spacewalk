--
-- $Id$
--

create table db_change_script_parsed (
   bug_id   number(12)
            constraint db_csp_bid_nn not null,
   seq_no   number(12)
            constraint db_csp_sno_nn not null,
   stmt_no  number(12)
            constraint db_csp_stno_nn not null,
   line_no  number(12)
            constraint db_csp_lno_nn not null,
   line     varchar2(1000)
            constraint db_csp_line_nn not null
);

COMMENT ON TABLE db_change_script_parsed IS 'DBCSP  Database change script parsed';

ALTER TABLE db_change_script_parsed ADD CONSTRAINT dbcsp_dbcsc_bug_id_seq_no_fk FOREIGN KEY
(
    bug_id,
    seq_no
)
 REFERENCES db_change_script(
    bug_id,
    seq_no
)
ON DELETE CASCADE
NOT DEFERRABLE
INITIALLY IMMEDIATE
ENABLE NOVALIDATE;
