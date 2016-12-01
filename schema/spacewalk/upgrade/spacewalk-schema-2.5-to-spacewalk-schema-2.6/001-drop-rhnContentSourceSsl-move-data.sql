-- Add columns
alter table rhnContentSource add ssl_ca_cert_id number constraint rhn_cs_cacertid_fk references rhnCryptoKey(id) on delete set null;
alter table rhnContentSource add ssl_client_cert_id number constraint rhn_cs_clcertid_fk references rhnCryptoKey(id) on delete set null;
alter table rhnContentSource add ssl_client_key_id number constraint rhn_cs_clkeyid_fk references rhnCryptoKey(id) on delete set null;

-- Copy values
update rhnContentSource cs set
    ssl_ca_cert_id = (select csssl.ssl_ca_cert_id from rhnContentSourceSsl csssl where csssl.content_source_id = cs.id),
    ssl_client_cert_id = (select csssl.ssl_client_cert_id from rhnContentSourceSsl csssl where csssl.content_source_id = cs.id),
    ssl_client_key_id = (select csssl.ssl_client_key_id from rhnContentSourceSsl csssl where csssl.content_source_id = cs.id);

