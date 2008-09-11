-- sql statements for multiorg work
alter table rhnChannel drop column parent_channel;
alter table web_contact drop column oracle_contact_id;
alter table web_customer drop column oracle_customer_number;
alter table web_customer drop column oracle_customer_id;
alter table web_customer drop column customer_type;
alter table web_customer drop column credit_application_completed;
--commit;

