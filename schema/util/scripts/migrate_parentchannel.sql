declare 
	cursor channels is 
	SELECT id,
               parent_channel,
               created,
               modified
        FROM rhnChannel 
        WHERE parent_channel is not null;
begin
	for ch in channels
        loop
	    insert into 
            rhnChannelParent (channel, parent_channel, created, modified) 
            values (ch.id, ch.parent_channel, ch.created, ch.modified);
        end loop;
        --alter table rhnChannel drop column parent_channel;
        --alter table web_contact drop column oracle_contact_id;
        --alter table web_customer drop column oracle_customer_number;
        --alter table web_customer drop column oracle_customer_id;
        --alter table web_customer drop column customer_type;
        --alter table web_customer drop column credit_application_completed;
        --commit;
end;
/
