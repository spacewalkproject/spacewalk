-- oracle equivalent source sha1 b14267384bc104605623a41b755e68e0103b5aa8

ALTER TABLE rhn_redirects drop CONSTRAINT RHN_RDRCT_RECUR_VALID;
ALTER TABLE rhn_redirects
    ADD CONSTRAINT RHN_RDRCT_RECUR_VALID
    CHECK (recurring in (0, 1));

ALTER TABLE rhn_redirects drop CONSTRAINT RHN_RDRCT_RECUR_FREQ_VALID;
ALTER TABLE rhn_redirects
    ADD CONSTRAINT RHN_RDRCT_RECUR_FREQ_VALID
    CHECK (recurring_frequency in (2,3,6));

ALTER TABLE rhn_redirects drop CONSTRAINT RHN_RDRCT_REC_DTYPE_VALID;
ALTER TABLE rhn_redirects
    ADD CONSTRAINT RHN_RDRCT_REC_DTYPE_VALID
    CHECK ( recurring_dur_type in (12,11,5,3,1) );
