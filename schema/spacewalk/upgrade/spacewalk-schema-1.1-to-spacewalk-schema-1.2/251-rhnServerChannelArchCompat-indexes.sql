CREATE INDEX rhn_sc_ac_caid
    ON rhnServerChannelArchCompat (channel_arch_id)
    TABLESPACE [[64k_tbs]];
drop index rhn_sc_ac_paid_caid;
