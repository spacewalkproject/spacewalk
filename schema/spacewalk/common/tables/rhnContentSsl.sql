
create table
rhnContentSsl
(
	id number not null
		constraint rhn_cssl_id_pk primary key,
	content_source_id number
		constraint rhn_cssl_csid_uq unique
		constraint rhn_cssl_csid_fk references rhnContentSource(id) on delete cascade,
        channel_family_id number 
                constraint rhn_cssl_cfid_uq unique
                constraint rhn_cssl_cfid_fk references rhnChannelFamily(id) on delete cascade,
	ssl_ca_cert_id number not null
		constraint rhn_cssl_cacertid_fk references rhnCryptoKey(id),
	ssl_client_cert_id number
		constraint rhn_cssl_clcertid_fk references rhnCryptoKey(id),
	ssl_client_key_id number
		constraint rhn_cssl_clkeyid_fk references rhnCryptoKey(id),
	constraint rhn_cssl_client_chk check(ssl_client_key_id is null or ssl_client_cert_id is not null),
        constraint rhn_cssl_type_chk check((content_source_id is null and channel_family_id is not null)
                                        or (content_source_id is not null and channel_family_id is null)),
	created timestamp with local time zone default(current_timestamp) not null,
	modified timestamp with local time zone default(current_timestamp) not null
)
enable row movement
;

create sequence rhn_contentssl_seq;

