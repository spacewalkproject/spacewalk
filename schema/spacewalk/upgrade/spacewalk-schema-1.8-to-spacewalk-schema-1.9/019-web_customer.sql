alter table web_customer
  add crash_file_sizelimit
      number default(2048) not null
      constraint web_customer_sizelimit_chk check (crash_file_sizelimit >= 0);
