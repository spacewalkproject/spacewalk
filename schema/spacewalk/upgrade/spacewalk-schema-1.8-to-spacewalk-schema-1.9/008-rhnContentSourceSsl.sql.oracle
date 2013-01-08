
create table
rhnContentSourceSsl
(
	id number not null
		constraint rhn_csssl_id_pk primary key,
	content_source_id number not null
		constraint rhn_csssl_csid_uq unique
		constraint rhn_csssl_csid_fk references rhnContentSource(id) on delete cascade,
	ssl_ca_cert_id number not null
		constraint rhn_csssl_cacertid_fk references rhnCryptoKey(id),
	ssl_client_cert_id number
		constraint rhn_csssl_clcertid_fk references rhnCryptoKey(id),
	ssl_client_key_id number
		constraint rhn_csssl_clkeyid_fk references rhnCryptoKey(id),
	constraint rhn_csssl_client_chk check(ssl_client_key_id is null or ssl_client_cert_id is not null),
	created timestamp with local time zone default(current_timestamp) not null,
	modified timestamp with local time zone default(current_timestamp) not null
)
enable row movement
;

create sequence rhn_contentsourcessl_seq;

