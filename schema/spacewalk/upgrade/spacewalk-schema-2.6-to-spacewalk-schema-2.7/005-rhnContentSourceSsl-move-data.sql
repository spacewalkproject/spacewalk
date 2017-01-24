insert into rhnContentSourceSsl
  (content_source_id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id)
select id, ssl_ca_cert_id, ssl_client_cert_id, ssl_client_key_id
  from rhnContentSource where
  ssl_ca_cert_id is not null and
  (ssl_client_key_id is null or ssl_client_cert_id is not null);

alter table rhnContentSource drop column ssl_ca_cert_id;
alter table rhnContentSource drop column ssl_client_cert_id;
alter table rhnContentSource drop column ssl_client_key_id;
